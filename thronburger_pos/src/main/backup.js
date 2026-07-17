'use strict';

const fs = require('fs');
const path = require('path');

/**
 * Copy the live DB into userData/backups once per app start, keeping only the
 * most recent 30 files. Filenames encode the local date/time. Uses the
 * better-sqlite3 online backup API so an in-use (WAL) DB copies cleanly.
 *
 * @param {import('better-sqlite3').Database} db   open database handle
 * @param {string} userDataDir                     app.getPath('userData')
 */
async function runDailyBackup(db, userDataDir) {
  const backupsDir = path.join(userDataDir, 'backups');
  fs.mkdirSync(backupsDir, { recursive: true });

  const stamp = localStamp();
  const target = path.join(backupsDir, `thronburger-${stamp}.db`);

  // Skip if a backup for this exact minute already exists (avoids duplicates
  // on rapid restarts).
  if (fs.existsSync(target)) return { skipped: true, file: target };

  try {
    await db.backup(target);
  } catch (err) {
    // Fallback to a plain file copy if the online backup API is unavailable.
    const src = db.name;
    if (src && fs.existsSync(src)) fs.copyFileSync(src, target);
  }

  pruneOldBackups(backupsDir, 30);
  return { skipped: false, file: target };
}

function localStamp() {
  const d = new Date();
  const p = (n) => String(n).padStart(2, '0');
  return (
    `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}` +
    `_${p(d.getHours())}-${p(d.getMinutes())}`
  );
}

function pruneOldBackups(dir, keep) {
  const files = fs
    .readdirSync(dir)
    .filter((f) => f.startsWith('thronburger-') && f.endsWith('.db'))
    .map((f) => ({ f, t: fs.statSync(path.join(dir, f)).mtimeMs }))
    .sort((a, b) => b.t - a.t);
  for (const { f } of files.slice(keep)) {
    try {
      fs.unlinkSync(path.join(dir, f));
    } catch (_) {
      /* ignore */
    }
  }
}

module.exports = { runDailyBackup };
