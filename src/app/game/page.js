import Footer from "@/src/components/Footer";
import GameCarousel from "@/src/components/GameCarousel";
import HeaderText from "@/src/components/HeaderText";
import MostPlayed from "@/src/components/MostPlayed";
import Navbar from "@/src/components/Navbar";

export default function Page() {
  return (
    <>
      <Navbar />
      <div className="pt-32 bg-sharp-black text-white px-14">
        <HeaderText
          header="Games"
          description="Hey champ! hit the bank and get your assets to play the games."
        />
        <GameCarousel />
        <MostPlayed />
        <Footer />
      </div>
    </>
  );
}
