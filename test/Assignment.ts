import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers, network } from "hardhat";
import { expandTo18Decimals, expandTo6Decimals, mineBlocks } from "./utilities/utilities";
import { IERC20, IERC20__factory, SushiBar, SushiBar__factory, SushiToken, SushiToken__factory } from "../typechain-types"
import { sushiTokenSol } from "../typechain-types/contracts";
import { experimentalAddHardhatNetworkMessageTraceHook } from "hardhat/config";
import { expect } from "chai";

 
 describe("Testing",async()=>{
    let bar: SushiBar;
    let sushi: SushiToken;
    let IERC20: IERC20;
    let owner: SignerWithAddress;
    let signers: SignerWithAddress[];
    beforeEach(async()=>{
    signers = await ethers.getSigners();
    owner = signers[0];
    sushi = await new SushiToken__factory(owner).deploy()
    bar = await new SushiBar__factory(owner).deploy(sushi.address);
    })

    it("Entering the stake",async()=>{
        await sushi.mint(signers[1].address,expandTo18Decimals(1000));
        await sushi.connect(signers[1]).approve(bar.address,expandTo18Decimals(1000))
        await bar.connect(signers[1]).enter(expandTo18Decimals(100));
        expect(await sushi.balanceOf(signers[1].address)).to.be.eq(expandTo18Decimals(900));
        expect(await sushi.balanceOf(bar.address)).to.be.eq(expandTo18Decimals(100));
    });

    it("unstaking the amount after 2 & before 4 days",async()=>{
        await sushi.mint(signers[1].address,expandTo18Decimals(1000));
        await sushi.connect(signers[1]).approve(bar.address,expandTo18Decimals(1000))
        await bar.connect(signers[1]).enter(expandTo18Decimals(100));
        await ethers.provider.send("evm_increaseTime",[259200]);
        await bar.connect(signers[1]).leave(expandTo18Decimals(100));
        expect(await sushi.balanceOf(signers[1].address)).to.be.eq(expandTo18Decimals(925));
    })

    it("unstaking the amount after 4 & before 6 days",async()=>{
        await sushi.mint(signers[1].address,expandTo18Decimals(1000));
        await sushi.connect(signers[1]).approve(bar.address,expandTo18Decimals(1000))
        await bar.connect(signers[1]).enter(expandTo18Decimals(100));
        await ethers.provider.send("evm_increaseTime",[432000]);
        await bar.connect(signers[1]).leave(expandTo18Decimals(100));
        expect(await sushi.balanceOf(signers[1].address)).to.be.eq(expandTo18Decimals(950));
    })

    it("unstaking the amount after 6 & before 8 days",async()=>{
        await sushi.mint(signers[1].address,expandTo18Decimals(1000));
        await sushi.connect(signers[1]).approve(bar.address,expandTo18Decimals(1000))
        await bar.connect(signers[1]).enter(expandTo18Decimals(100));
        await ethers.provider.send("evm_increaseTime",[604800]);
        await bar.connect(signers[1]).leave(expandTo18Decimals(100));
        expect(await sushi.balanceOf(signers[1].address)).to.be.eq(expandTo18Decimals(975));
    })

    it("unstaking the amount after 8 days",async()=>{
        await sushi.mint(signers[1].address,expandTo18Decimals(1000));
        await sushi.connect(signers[1]).approve(bar.address,expandTo18Decimals(1000))
        await bar.connect(signers[1]).enter(expandTo18Decimals(100));
        await ethers.provider.send("evm_increaseTime",[777600]);
        await bar.connect(signers[1]).leave(expandTo18Decimals(100));
        expect(await sushi.balanceOf(signers[1].address)).to.be.eq(expandTo18Decimals(1000));
    })

    it("Trying to unstake before two days",async()=>{
        await sushi.mint(signers[1].address,expandTo18Decimals(1000));
        await sushi.connect(signers[1]).approve(bar.address,expandTo18Decimals(1000))
        await bar.connect(signers[1]).enter(expandTo18Decimals(100));
        await ethers.provider.send("evm_increaseTime",[86400]);
        await expect( bar.connect(signers[1]).leave(expandTo18Decimals(100))).to.be.revertedWith("Can't be unstaked");
    })

    it("User who has not staked anything tries to unstake",async()=>{
        await sushi.mint(signers[1].address,expandTo18Decimals(1000));
        await sushi.connect(signers[1]).approve(bar.address,expandTo18Decimals(1000))
        await bar.connect(signers[1]).enter(expandTo18Decimals(100));
        await expect( bar.connect(signers[2]).leave(expandTo18Decimals(100))).to.be.revertedWith("No amount staked");
        
    })
 })