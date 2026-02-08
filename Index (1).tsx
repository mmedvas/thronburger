import { Header } from "@/components/Header";
import { Hero } from "@/components/Hero";
import { About } from "@/components/About";
import { Menu } from "@/components/Menu";
import { MenuGallery } from "@/components/MenuGallery";
import { EventInfo } from "@/components/EventInfo";
import { Footer } from "@/components/Footer";
import { PWAInstallPrompt } from "@/components/PWAInstallPrompt";

const Index = () => {
  return (
    <div className="min-h-screen">
      <Header />
      <main>
        <Hero />
        <About />
        <Menu />
        <MenuGallery />
        <EventInfo />
      </main>
      <Footer />
      <PWAInstallPrompt />
    </div>
  );
};

export default Index;
