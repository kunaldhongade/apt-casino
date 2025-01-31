"use client";
import AccountCircleIcon from "@mui/icons-material/AccountCircle";
import SportsEsportsIcon from "@mui/icons-material/SportsEsports";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useAccount } from "wagmi";
import GradientBorderButton from "./GradientBorderButton";
import LaunchGameButton from "./LaunchGameButton";

export default function Navbar() {
  const pathname = usePathname();
  const { isConnected } = useAccount();
  const router = useRouter();
  const navLinks = [
    {
      name: "Home",
      path: "/",
      classes: "text-hover-gradient-home",
    },
    {
      name: "Game",
      path: "/game",
      classes: "text-hover-gradient-game",
    },
    {
      name: "Bank",
      path: "/bank",
      classes: "text-hover-gradient-bank",
    },
  ];

  const handleProfileClick = () => {
    router.push("/profile");
  };

  return (
    <nav className="bg-[#070005] fixed w-full z-20">
      <div className="flex w-full items-center justify-between py-6 px-8">
        <a href="/" className="logo">
          <Image
            src="/PowerPlay.png"
            alt="powerplay image"
            width={172}
            height={15}
          ></Image>
        </a>
        <div className="font-display flex gap-12">
          {navLinks.map(({ name, path, classes }, index) => (
            <Link
              className={`${classes} ${
                path === pathname ? "before:opacity-0" : ""
              }`}
              key={index}
              href={path}
            >
              {name}
            </Link>
          ))}
        </div>
        <div className="buttons flex gap-3">
          {isConnected ? (
            <div className="relative group">
              {/* <GradientBorderButton classes="text-white"> */}
              <appkit-button />
              {/* </GradientBorderButton> */}
              <div className="bg-dark-pink hidden absolute w-[120%] right-0  cursor-pointer group-hover:flex flex-col gap-6 text-lg text-white">
                <span
                  onClick={handleProfileClick}
                  className="flex p-2 items-center gap-3 hover:bg-dark-kiss "
                >
                  <AccountCircleIcon />
                  <span>Profile</span>
                </span>
                <span
                  onClick={() => router.push("/game")}
                  className="flex p-2 items-center gap-3 hover:bg-dark-kiss "
                >
                  <SportsEsportsIcon />
                  <span>Games</span>
                </span>
              </div>
            </div>
          ) : (
            <LaunchGameButton />
          )}
        </div>
      </div>
      <div className="w-full h-0.5 magic-gradient"></div>
    </nav>
  );
}
