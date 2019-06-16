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
        "0x00f32431ef59dc86f6fde8b00e7be5f7ed40c4ab55aaab9c011c3f6f06baac28", 
        "0x2453a5b0f3aaacb807bef7728cdd5cf1f06a8798ecc4779b0847d56973c0013e"]
    const updateB = [
        ["0x0963f935bde28c15f36e29d9994e67119f1284b695f12168726e143bf90f4dc8", 
        "0x167385bbf6244548dc5b5d0ae47dbb6d8c51407e5a5b855693bfffcbbaa62ffc"],
        ["0x29c124dd292e789e722d990a834f077297b17ffd5a20b82d6f3b2367c38ab8f7", 
        "0x26002bbef048d42214390ee20612a24935a5991a58ab1cb7d55ca58232cfb634"]]
    const updateC = [
        "0x015b93767e1e050e89ca8453db1d36321db9eacb603fc0c5d2dfc074223a47e3", 
        "0x1de59f17f24e33aedf5e56e91bf9e47d65f65cd860b26c3a0ce92da9d11799b4"]
    const updateInput = [
        "0x1a52b20785401603b64b1cc3db168f648e96d52af9fc896396e76e068ffb7547",
        "0x01733dbb544757c24a3a727be553af957cb39260ab82b7000957b4db1d98cc83",
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
        "9147603832976282322177802237335033023892550539422420889941340634444804843588",
        "17087000614363200202425883762664953902375829596010825089495865991695670487372"
      ]
      const position = [1, 0]
      const txRoot = 
      "655926317945542797074993632917009959927083450268202759196407232656349645955"
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