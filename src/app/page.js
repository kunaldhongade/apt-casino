import FeatureGameSection from "@/src/components/FeatureGameSection";
import FeatureSection from "@/src/components/FeatureSection";
import Footer from "@/src/components/Footer";
import HeroSection from "@/src/components/HeroSection";
import LetsPlaySection from "@/src/components/LetsPlaySection";
import Navbar from "@/src/components/Navbar";
import SponsorSection from "@/src/components/SponsorSection";

export default function Home() {
  return (
    <div className="bg-[#070005]">
      <Navbar />
      <HeroSection />
      {/* <FeatureSection /> */}
      <FeatureGameSection />
      <LetsPlaySection />
      <Footer />
    </div>
  );
}
