// import AiModal from "@/components/AiModal";
import ContextProvider from "@/src/context/index.tsx";
import "@/src/styles/globals.css";
import { headers } from "next/headers";

export const metadata = {
  title: "APT-Casino",
  description: "Web3 gaming arena",
};

export default async function RootLayout({ children }) {
  const headersObj = await headers();
  const cookies = headersObj.get("cookie");

  return (
    <html lang="en">
      <body>
        {/* <AiModal /> */}
        <ContextProvider cookies={cookies}>{children}</ContextProvider>
      </body>
    </html>
  );
}
