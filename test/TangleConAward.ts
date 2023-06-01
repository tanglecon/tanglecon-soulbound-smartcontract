import {expect} from "chai";
import hre from "hardhat";
import {loadFixture} from "@nomicfoundation/hardhat-network-helpers";

describe("TangleConAwards", function () {

    async function deployAwardFixture() {
        const [owner, otherAccount] = await hre.ethers.getSigners();
        const Award = await hre.ethers.getContractFactory("TangleConAwards");
        //deploy the smart contract with the constructor
        const award = await Award.connect(owner).deploy(".json");
        const contract = await award.deployed();

        return {Award, award, contract, owner, otherAccount}
    }


    it("Should set the right owner", async function () {
        const {owner, contract} = await loadFixture(deployAwardFixture);
        // assert that the value is correct
        expect(owner.address).to.equal(await contract.owner());
    });

    it("Should set the baseURI for each token individualy", async function () {
        const {contract} = await loadFixture(deployAwardFixture);
        const url1 = "https://arweave.net/e6GaXSMjnu06fkiN7KpgREL5xIhVpghiLHddTmZEdaM/";
        const url2 = "BaseURI2/";
        const suffix = ".json"

        await contract.mapAwardEditionURI(1,url1);
        await contract.mapAwardEditionURI(2,url2);
        await contract.mapAwardID(1,2,1);
        await contract.mapAwardID(3,3,2);
        for (let i = 1; i < 3; i++){
            expect(await contract.uri(i)).to.equal(url1+i+suffix);
        }
        for (let i = 3; i < 6; i++){
            expect(await contract.uri(i)).to.equal(url2+i+suffix);
        }
    });

    it("Should revert on non owner calls", async function () {
        const {contract, otherAccount} = await loadFixture(deployAwardFixture);
        const url1 = "BaseURI1/";

        await expect(contract.connect(otherAccount).mapAwardEditionURI(1,url1)).to.be.revertedWith("Ownable: caller is not the owner");
        await expect(contract.connect(otherAccount).mapAwardID(1,2,1)).to.be.revertedWith("Ownable: caller is not the owner");
        await expect(contract.connect(otherAccount).airdropAwards(1, [otherAccount.address])).to.be.revertedWith("Ownable: caller is not the owner");
        await expect(contract.connect(otherAccount).adminBurnAward(otherAccount.address, 1)).to.be.revertedWith("Ownable: caller is not the owner");
        await expect(contract.connect(otherAccount).setSuffix("overwrite")).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should overwrite the awardEntry URI", async function () {
        const {contract} = await loadFixture(deployAwardFixture);
        const url1 = "BaseURI/";
        const url2 = "OverwrittenURI/";
        const suffix = ".json"

        await contract.mapAwardEditionURI(1,url1);
        await contract.mapAwardID(1,2,1);
        for (let i = 1; i < 3; i++){
            expect(await contract.uri(i)).to.equal(url1+i+suffix);
        }
        //testing if uri overwriting works
        await contract.mapAwardEditionURI(1,url2);
        for (let i = 1; i < 3; i++){
            expect(await contract.uri(i)).to.equal(url2+i+suffix);
        }
    });

    it("Should let admin airdrop to and burn sbts from other accounts", async function () {
        const { contract, owner, otherAccount } = await loadFixture(deployAwardFixture);
        const userAccount = otherAccount.address;

        //userAccount should have 0 SBTs at first
        expect(await contract.balanceOf(userAccount, 1)).to.equal(0);

        await contract.airdropAwards(1, [userAccount]);

        //now it should be 1
        expect(await contract.balanceOf(userAccount, 1)).to.equal(1);

        await contract.adminBurnAward(userAccount, 1);

        //sbt gets forcibly removed, turning the count back to 0
        expect(await contract.balanceOf(userAccount, 1)).to.equal(0);

      });

    it("Should let airdrop sbt to other account and let other account burn owned sbts", async function () {
        const { contract, owner, otherAccount } = await loadFixture(deployAwardFixture);
        const userAccount = otherAccount.address;
        const ownerAccount = owner.address;

        //userAccount should have 0 SBTs at first
        expect(await contract.balanceOf(userAccount, 1)).to.equal(0);
        expect(await contract.balanceOf(ownerAccount, 2)).to.equal(0);

        await contract.airdropAwards(1, [userAccount]);
        await contract.airdropAwards(2, [ownerAccount]);

        //now it should be 1
        expect(await contract.balanceOf(userAccount, 1)).to.equal(1);
        expect(await contract.balanceOf(ownerAccount, 2)).to.equal(1);

        await contract.connect(otherAccount).burnAward(1);
        await contract.burnAward(2);

        //userAccount should have 0 SBTs again
        expect(await contract.balanceOf(userAccount, 1)).to.equal(0);
        expect(await contract.balanceOf(ownerAccount, 2)).to.equal(0);

      });

  });
