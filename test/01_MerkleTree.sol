pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/MerkleTree.sol";


contract TestMerkleTree
{
	using MerkleTree for MerkleTree.Data;

	function testUniqueLeafs ()
		public
	{
		Assert.equal(MerkleTree.GetUniqueLeaf(20, 20, 0), 6738165491478210350639451800403024427867073896603076888955948358229240057870, "Unique leaf mismatch 20 20!");

		Assert.equal(MerkleTree.GetUniqueLeaf(2, 2, 0), 21534879888322772601810176771999178940739467644392123609236489175629034941722, "Unique leaf mismatch 2 2!");

		Assert.equal(MerkleTree.GetUniqueLeaf(0, 0, 0), 2544023609834722662089612003212769975105508295482723304413974529614913939747, "Unique leaf mismatch 2 2!");
	}

	MerkleTree.Data tree1;

	function testUniqueLeaf ()
		public
	{
		// ....
	}

	function testTreeInsert ()
		public
	{
		uint256 leaf_0 = 3703141493535563179657531719960160174296085208671919316200479060314459804651;
		tree1.Insert(leaf_0);

		uint256 leaf_1 = 134551314051432487569247388144051420116740427803855572138106146683954151557;
		uint256 leaf_1_root;
		uint256 leaf_1_offset;

		(leaf_1_root, leaf_1_offset) = tree1.Insert(leaf_1);

		// Verify root after insertion
		uint256 new_root = tree1.GetRoot();
		Assert.equal(new_root, leaf_1_root, "Root must match after insert");
		Assert.equal(new_root, 14972246236048249827985830600768475898195156734731557762844426864943654467818, "Root mismatch!");
		
		// Verify leaf offset 0
		Assert.equal(tree1.GetLeaf(0, 0), 3703141493535563179657531719960160174296085208671919316200479060314459804651, "Leaf mismatch 0 0");
		Assert.equal(tree1.GetLeaf(1, 0), 3075442268020138823380831368198734873612490112867968717790651410945045657947, "Leaf mismatch 1 0");
		Assert.equal(tree1.GetLeaf(2, 0), 10399465128272526817755257959020023025563587559350936053132523411421423507430, "Leaf mismatch 2 0");

		// Verify leaf offset 1
		Assert.equal(tree1.GetLeaf(1, 1), 17296471688945713021042054900108821045192859417413320566181654591511652308323, "Leaf mismatch 1 1");
		Assert.equal(tree1.GetLeaf(2, 1), 4832852105446597958495745596582249246190817345027389430471458078394903639834, "Leaf mismatch 2 1");
		Assert.equal(tree1.GetLeaf(13, 1), 14116139569958633576637617144876714429777518811711593939929091541932333542283, "Leaf mismatch 13 1");
		Assert.equal(tree1.GetLeaf(22, 1), 16077039334695461958102978289003547153551663194787878097275872631374489043531, "Leaf mismatch 22 1");

		// Validate the proof
		uint256[29] memory path_0;
		bool[29] memory bits_0;
		(path_0, bits_0) = tree1.GetProof(0);
		Assert.equal(tree1.VerifyPath(leaf_0, path_0, bits_0), true, "Own path didn't validate!");

		// Validate individual items from the path
		Assert.equal(path_0[0], 134551314051432487569247388144051420116740427803855572138106146683954151557, "Path 0 not match");

		Assert.equal(path_0[1], 17296471688945713021042054900108821045192859417413320566181654591511652308323, "Path 1 not match");

		Assert.equal(path_0[28], 12153512749608688970226014453322261962108142410782369348825826565095395587383, "Path 28 not match");
	}
}