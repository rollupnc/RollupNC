const {waffle, ethers} = require("hardhat");
import { ContractFactory, BigNumber} from "ethers";
const hre = require('hardhat')
const assert = require('assert');
const cls = require("circomlibjs");
// var RollupNC = artifacts.require("RollupNC");
// var TokenRegistry = artifacts.require("TokenRegistry")
// var TestToken = artifacts.require("TestToken")

/*
    Here we want to test the smart contract's deposit functionality.
*/

describe("RollupNC", () => {
    let accounts;
    let rollupNC;
    let tokenRegistry;
    let testToken;
    let mimc;
    let miMCMerkle;

    before(async function () {
        accounts = await hre.ethers.getSigners()

        const SEED = "mimc";
        let abi = cls.mimc7Contract.abi
        let createCode = cls.mimc7Contract.createCode
        let factory = new ContractFactory(
            abi, createCode(SEED, 91), accounts[0]
        )
        mimc = await factory.deploy()

        factory = await ethers.getContractFactory("MiMCMerkle");
        miMCMerkle = await factory.deploy(mimc.address)
        await miMCMerkle.deployed()

        factory = await ethers.getContractFactory("TokenRegistry");
        tokenRegistry = await factory.deploy(accounts[0].address)
        await tokenRegistry.deployed()

        factory = await ethers.getContractFactory("RollupNC");
        rollupNC = await factory.deploy(mimc.address, miMCMerkle.address, tokenRegistry.address)
        await rollupNC.deployed()

        factory = await ethers.getContractFactory("TestToken");
        testToken = await factory.connect(accounts[3]).deploy()
        await testToken.deployed()
    });

    // ----------------------------------------------------------------------------------

    it("should set rollupNC address", async () => {
        let setRollupNC = await tokenRegistry.connect(accounts[0]).setRollupNC(rollupNC.address, { from: accounts[0].address });
        assert(setRollupNC, 'setRollupNC failed')
    });

    // ----------------------------------------------------------------------------------


    // const tokenContractAddr = "0xaD6D458402F60fD3Bd25163575031ACDce07538D"

    it("should register token", async () => {
        let registerToken = await rollupNC.connect(accounts[1]).registerToken(testToken.address, { from: accounts[1].address })
        assert(registerToken, "token registration failed");
    });

    // ----------------------------------------------------------------------------------

    it("should approve token", async () => {
        let approveToken = await rollupNC.connect(accounts[0]).approveToken(testToken.address, { from: accounts[0].address })
        assert(approveToken, "token registration failed");
	});
	
    // ----------------------------------------------------------------------------------
    it("should approve RollupNC on TestToken", async () => {
        let approveToken = await testToken.connect(accounts[3]).approve(
            rollupNC.address, 1700,
            {from: accounts[3].address}
        )
        assert(approveToken, "approveToken failed")
    });

    // ----------------------------------------------------------------------------------

    const pubkeyCoordinator = [
        '5686635804472582232015924858874568287077998278299757444567424097636989354076',
        '20652491795398389193695348132128927424105970377868038232787590371122242422611'
    ]
    const pubkeyA = [
        '5188413625993601883297433934250988745151922355819390722918528461123462745458',
        '12688531930957923993246507021135702202363596171614725698211865710242486568828'
    ]
    const pubkeyB = [
        '3765814648989847167846111359329408115955684633093453771314081145644228376874',
        '9087768748788939667604509764703123117669679266272947578075429450296386463456'
    ]

    it("should make first batch of deposits", async () => {
        // zero leaf
        let deposit0 = await rollupNC.connect(accounts[0]).deposit([0, 0], 0, 0, { from: accounts[0].address })
        assert(deposit0, "deposit0 failed");

        // operator account
        let deposit1 = await rollupNC.connect(accounts[0]).deposit(pubkeyCoordinator, 0, 0, { from: accounts[0].address })
        assert(deposit1, "deposit1 failed");

        // Alice account
        let deposit2 = await rollupNC.connect(accounts[3]).deposit(pubkeyA, 1000, 2, { from: accounts[3].address })
        assert(deposit2, "deposit2 failed");

        // Bob account
        let deposit3 = await rollupNC.connect(accounts[2]).deposit(pubkeyB, 20, 1, { value: 20, from: accounts[2].address })
        assert(deposit3, "deposit3 failed");

        await rollupNC.currentRoot().then(console.log)

	});

    // ----------------------------------------------------------------------------------

    const first4Hash = '7050347282514471087563830153856643063364567885025682963692567600170667148976';
    const first4HashPosition = [0, 0]
    const first4HashProof = [
        '6180012883826996691682233524035352980520561433337754209809143632670877151717',
        '20633846227573655562891472654875498275532732787736199734105126629336915134506'
    ]

    it("should process first batch of deposits", async () => {
        let processDeposit1
        try {
            processDeposit1 = await rollupNC.connect(accounts[0]).processDeposits(
                2,
                first4HashPosition,
                first4HashProof,
                { from: accounts[0].address }
            )
        } catch (error){
            console.log('processDeposits revert reason', error)
        }
        assert(processDeposit1, "processDeposit1 failed")
        await rollupNC.currentRoot().then(console.log)
    })

    // ----------------------------------------------------------------------------------

    const pubkeyC = [
        '1762022020655193103898710344498807340207430243997238950919845130297394445492',
        '8832411107013507530516405716520512990480512909708424307433374075372921372064'
    ]
    const pubkeyD = [
        '14513915892014871125822366308671332087536577613591524212116219742227565204007',
        '6808129454002661585298671177612815470269050142983438156881769576685169493119'
    ]
    const pubkeyE = [
        '20300689398049417995453571887069099991639845657899598560126131780687733391655',
        '3065218658444486645254031909815995896141455256411822883766560586158143575806'
    ]
    const pubkeyF = [
        '4466175261537103726537785696466743021163534542754750959075936842928329438365',
        '15538720798538530286618366590344759598648390726703115865880683329910616143012'
    ]

    it("should make second batch of deposits", async () => {
        // zero leaf
        let deposit4 = await rollupNC.connect(accounts[3]).deposit(pubkeyC, 200, 2, { from: accounts[3].address })
        assert(deposit4, "deposit4 failed");

        // operator account
        let deposit5 = await rollupNC.connect(accounts[4]).deposit(pubkeyD, 100, 1, { value: 100, from: accounts[4].address })
        assert(deposit5, "deposit5 failed");

        // Alice account
        let deposit6 = await rollupNC.connect(accounts[3]).deposit(pubkeyE, 500, 2, { from: accounts[3].address })
        assert(deposit6, "deposit6 failed");

        // Bob account
        let deposit7 = await rollupNC.connect(accounts[6]).deposit(pubkeyF, 20, 1, { value: 20, from: accounts[6].address })
        assert(deposit7, "deposit7 failed");
        await rollupNC.currentRoot().then(console.log)

    });


    // ----------------------------------------------------------------------------------

    let second4HashPosition = [1, 0]
    let second4HashProof = [
        first4Hash,
        '20633846227573655562891472654875498275532732787736199734105126629336915134506'
    ]

    it("should process second batch of deposits", async () => {
        let processDeposit2 = await rollupNC.connect(accounts[0]).processDeposits(
            2,
            second4HashPosition,
            second4HashProof,
            { from: accounts[0].address }
        )
        assert(processDeposit2, "processDeposit2 failed")
        await rollupNC.currentRoot().then(console.log)
    })

    // ----------------------------------------------------------------------------------
    let updateProof = require("../circuits/update_state_js/test_1_update_proof.json")
    const updateA = [
        updateProof.pi_a[0], updateProof.pi_a[1]
    ]
    const updateB = [
        [updateProof.pi_b[0][1], updateProof.pi_b[0][0]],
        [updateProof.pi_b[1][1], updateProof.pi_b[1][0]],
    ]
    const updateC = [
        updateProof.pi_c[0], updateProof.pi_c[1]
    ]
    const updateInput = require("../circuits/update_state_js/test_1_update_public.json")

    it("should accept valid state updates", async () => {
        let validStateUpdate = await rollupNC.updateState(
            updateA, updateB, updateC, updateInput
        );
        assert(validStateUpdate, "invalid state transition");
        await rollupNC.currentRoot().then(console.log)

    });

    // ----------------------------------------------------------------------------------
    const pubkey_from = [
        "1762022020655193103898710344498807340207430243997238950919845130297394445492",
        "8832411107013507530516405716520512990480512909708424307433374075372921372064"
    ]
    const index = 4;
    const nonce = 0;
    const amount = 200;
    const token_type_from = 2;
    const position = [1, 0]
    const txRoot =
        "14053325031894235002744541221369412510941171790893507881802249870625790656164"
    const recipient = "0xC33Bdb8051D6d2002c0D80A1Dd23A1c9d9FC26E4"

    let withdraw_proof = require("../circuits/withdraw_signature_js/test_1_withdraw_proof.json")
    const withdrawA = [
        withdraw_proof.pi_a[0], withdraw_proof.pi_a[1]
    ]
    const withdrawB = [
        [withdraw_proof.pi_b[0][1], withdraw_proof.pi_b[0][0]],
        [withdraw_proof.pi_b[1][1], withdraw_proof.pi_b[1][0]],
    ]
    const withdrawC = [
        withdraw_proof.pi_c[0], withdraw_proof.pi_c[1]
    ]
    // const withdrawInput = require("../circuits/withdraw_signature_js/test_1_withdraw_public.json")

    const proof = [
        "7098655440094613198080048525953255637313939645539008401738087356838738631323",
        "2608995037327946514938120021228249424325886260519057431141160511257427858790"
    ]

    it("should accept valid withdrawals", async () => {
        const txInfo = {
            pubkeyX: pubkey_from[0],
            pubkeyY: pubkey_from[1],
            index: index,
            toX: BigNumber.from(0),
            toY: BigNumber.from(0),
            nonce: BigNumber.from(nonce),
            amount: BigNumber.from(amount),
            token_type_from: BigNumber.from(token_type_from),
            txRoot: txRoot,
            position: position,
            proof: proof,
        }
        let validWithdraw = await rollupNC.connect(accounts[3]).withdraw(
            txInfo, recipient,
            withdrawA, withdrawB, withdrawC,
            {from: accounts[3].address}
        );
        assert(validWithdraw, "invalid withdraw");
    });
});
