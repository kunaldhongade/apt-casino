"use client";

export default function ConnectWalletButton() {
  // const onClickHandler = () => {
  //   // setDefaultTabIndex(1); // Set the default tab index to 1, which corresponds to the Ethereum tab
  //   setShowAuthFlow(true);
  // };

  return (
    <div className="bg-transparent hover-gradient-shadow rounded-xl p-0.5 cursor-pointer">
      <div
        className="bg-transparent rounded-xl py-1 px-2 h-full flex items-center "
        // onClick={onClickHandler}
      >
        <appkit-button />
      </div>
    </div>
  );
}
