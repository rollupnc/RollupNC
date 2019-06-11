var RollupNC = artifacts.require("RollupNC");
var TokenRegistry = artifacts.require("TokenRegistry")

/*
    Here we want to test the smart contract sdeposit functionality.
*/ 

contract("RollupNC deposit", async accounts => {

    it("should set rollupNC address", async() => {
        let tokenRegistry = await TokenRegistry.deployed();
        let rollupNC = await RollupNC.deployed();
        let setRollupNC = await tokenRegistry.setRollupNC(rollupNC.address, {from: accounts[0]});
        assert(setRollupNC, 'setRollupNC failed')
    })

    const daiRopstenAddr = "0xaD6D458402F60fD3Bd25163575031ACDce07538D"

    it("should register token", async () => {
        let rollupNC = await RollupNC.deployed();
        let registerToken = await rollupNC.registerToken(daiRopstenAddr, {from: accounts[1]})
        assert(registerToken, "token registration failed");
    });

    it("should approve token", async () => {
        let rollupNC = await RollupNC.deployed();
        let approveToken = await rollupNC.approveToken(daiRopstenAddr, {from: accounts[0]})
        assert(approveToken, "token registration failed");
    });

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
        let rollupNC = await RollupNC.deployed();
        // zero leaf
        let deposit0 = await rollupNC.deposit([0,0], 0, 0, {from: accounts[0]})
        assert(deposit0, "deposit0 failed");

        // operator account
        let deposit1 = await rollupNC.deposit(pubkeyCoordinator, 0, 0, {from: accounts[0]})
        assert(deposit1, "deposit1 failed");

        // Alice account
        let deposit2 = await rollupNC.deposit(pubkeyA, 1000, 2, {from: accounts[1]})
        assert(deposit2, "deposit2 failed");

        // Bob account
        let deposit3 = await rollupNC.deposit(pubkeyB, 20, 1, {value: 1000, from: accounts[2]})
        assert(deposit3, "deposit3 failed");

        await rollupNC.currentRoot().then(console.log)

    });

    const first4Hash = '7050347282514471087563830153856643063364567885025682963692567600170667148976';
    const first4HashPosition = [0, 0]
    const first4HashProof = [
        '6180012883826996691682233524035352980520561433337754209809143632670877151717',
        '20633846227573655562891472654875498275532732787736199734105126629336915134506'
    ]

    it("should process first batch of deposits", async () => {
        let rollupNC = await RollupNC.deployed();
        let processDeposit1 = await rollupNC.processDeposits(
            first4HashPosition,
            first4HashProof,
            {from: accounts[0]}
        )
        assert(processDeposit1, "processDeposit1 failed")
        await rollupNC.currentRoot().then(console.log)
    })

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
        let rollupNC = await RollupNC.deployed();
        // zero leaf
        let deposit4 = await rollupNC.deposit(pubkeyC, 200, 2, {from: accounts[3]})
        assert(deposit4, "deposit4 failed");

        // operator account
        let deposit5 = await rollupNC.deposit(pubkeyD, 100, 1, {value: 1000, from: accounts[4]})
        assert(deposit5, "deposit5 failed");

        // Alice account
        let deposit6 = await rollupNC.deposit(pubkeyE, 500, 2, {from: accounts[5]})
        assert(deposit6, "deposit6 failed");

        // Bob account
        let deposit7 = await rollupNC.deposit(pubkeyF, 20, 1, {value: 1000, from: accounts[6]})
        assert(deposit7, "deposit7 failed");
        await rollupNC.currentRoot().then(console.log)

    });

    second4HashPosition = [1, 0]
    second4HashProof = [
        first4Hash,
        '20633846227573655562891472654875498275532732787736199734105126629336915134506'
    ]

    it("should process second batch of deposits", async () => {
        let rollupNC = await RollupNC.deployed();
        let processDeposit2 = await rollupNC.processDeposits(
            second4HashPosition,
            second4HashProof,
            {from: accounts[0]}
        )
        assert(processDeposit2, "processDeposit2 failed")
        await rollupNC.currentRoot().then(console.log)
    })

    const updateA = [
        "0x0f1baedd66ca51288fea85de83d4db6018588e4f3e494d9f49837b541d037edc",
        "0x1a449d046ccc37424c3925f95aeceae5bc01f8554d5f773eb8d5d339f19f0d77"]
    const updateB = [
        ["0x1655b9d96c2a157baf7ae8e09cda18680c391cdd504f1de2f811b62aa60aac77",
         "0x08846aa2499816ad822b874ed6a67fc53d3df3e04eecd747f37102de7cbf4217"],
         ["0x0b60f81862b1b90c9e750939adb70021bfa184443fb8fd0a4532258fb006f2ec", 
         "0x0011e80537fcb1e321c9a489ff2af2f3bd9f83b2bf73dc55b1bed254751eacba"]]
    const updateC = [
        "0x259cc06cd0cbd9244fba753eed2c8c692bfb68c8ba1fb0fb78c068bdd1707861",
         "0x0a200a8e284bdb07142de5c24db0bae27193be0efd4922aec713f8358c8f1765"]
    const updateInput = [
        "0x1a52b20785401603b64b1cc3db168f648e96d52af9fc896396e76e068ffb7547",
        "0x0f98200e29638cb637d4ce0f18d8fcd9166880c072c0085d539b01d42c22a81d",
        "0x293a77d2ffc919fec84075c4fc2f86d3d1c34570fbe52eed3f99041a720c38d2"]

    // it("should reject invalid state updates", async () => {
  
    // });
  
    it("should accept valid state updates", async () => {
      let rollupNC = await RollupNC.deployed();
      let validStateUpdate = await rollupNC.updateState(
            updateA, updateB, updateC, updateInput
          );
      assert(validStateUpdate, "invalid state transition");
      await rollupNC.currentRoot().then(console.log)
  
    });


    const pubkey_from = [
        "1762022020655193103898710344498807340207430243997238950919845130297394445492",
        "8832411107013507530516405716520512990480512909708424307433374075372921372064"
      ]
      const nonce = 0;
      const amount = 200;
      const token_type_from = 2;
      const proof = [
        "14531446347543507823064235057843916202619496233804832613581857015484624277653",
        "18254291533780430427259061798213882541801401402725032906945856976051805416542"
        ]
      const position = [1, 0]
      const txRoot = 
      "7053474720276417193178914001357165144196208978730163381613334488911018371101"
      const recipient = "0xC33Bdb8051D6d2002c0D80A1Dd23A1c9d9FC26E4"
      const withdrawA = [
        "0x2c54372cad388d7e445489530a93e7c648b825ff5cd18e65526b11df8e9a5a8b", 
        "0x2985487009964527c301b2930a5663c516e6dfa232e27f761047af2d95afc91c"]
      const withdrawB = [
        ["0x0dbe5a77aa4d004942268ffac90b5adfa35f3a3b5ce426f4a23e3a287ce4fd34",
         "0x23250aa3d63898a457e07cb2a42417097ca36bcba65c40c30f2149e3c9040ff6"],
         ["0x10fa8752666c9e8bf8d88c1470b6dc1544438247314cb6998f2f532547c8c179",
          "0x0dc0721e9c65b9008eff2ee719855937b233fbc585cd6f2e3bc9fa8a3f9643ec"]]
      const withdrawC = [
        "0x1848acdb157b27c3fcb15cfa4bd09cdc116fafabebd9beddb8ce6486edf185d2", 
        "0x18893ba046ebc078a3dfc615bbd08cb9e390084eb2a91edf758b3ea4da9ea3c7"]
    
      // it("should reject invalid withdrawals", async () => {
    
      // });
    
      it("should accept valid withdrawals", async () => {
        let rollupNC = await RollupNC.deployed();
        let validWithdraw = await rollupNC.withdraw(
              pubkey_from, [nonce, amount, token_type_from], 
              [position, proof], txRoot, recipient,
              withdrawA, withdrawB, withdrawC
            );
        assert(validWithdraw, "invalid withdraw");
      });
    
});