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
        '1891156797631087029347893674931101305929404954783323547727418062433377377293',
        '14780632341277755899330141855966417738975199657954509255716508264496764475094'
    ]
    const pubkeyA = [
        '16854128582118251237945641311188171779416930415987436835484678881513179891664',
        '8120635095982066718009530894702312232514551832114947239433677844673807664026'
    ]
    const pubkeyB = [
        '17184842423611758403179882610130949267222244268337186431253958700190046948852',
        '14002865450927633564331372044902774664732662568242033105218094241542484073498'
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

    const first4Hash = '7987453866078611028599950030116106120762611542409392413435373272225955372850';
    const first4HashPosition = [0, 0]
    const first4HashProof = [
        '10979797660762940206903140898034771814264102460382043487394926534432430816033',
        '4067275915489912528025923491934308489645306370025757488413758815967311850978'
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
        '1490516688743074134051356933225925590384196958316705484247698997141718773914',
        '18202685495984068498143988518836859608946904107634495463490807754016543014696'
    ]
    const pubkeyD = [
        '605092525880098299702143583094084591591734458242948998084437633961875265263',
        '5467851481103094839636181114653589464420161012539785001778836081994475360535'
    ]
    const pubkeyE = [
        '6115308589625576351618964952901291926887010055096213039283160928208018634120',
        '7748831575696937538520365609095562313470874985327756362863958469935920020098'
    ]
    const pubkeyF = [
        '8497552053649025231196693001489376949137425670153512736866407813496427593491',
        '2919902478295208415664305012229488283720319044050523257046455410971412405951'
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
