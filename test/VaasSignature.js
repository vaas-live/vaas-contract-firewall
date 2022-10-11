const { ethers } = require("hardhat");
const { expect } = require("chai");
var axios = require('axios');

describe("VaasSignature", function () {
  it("Verify Signature Local Key", async function () {
    const accounts = await ethers.getSigners(2)

    var finalUserWallet = accounts[1];
    console.log('Illuvium user address=', finalUserWallet.address);

    //
    // deploy the contract
    //
    const VaasAddressScreening = await ethers.getContractFactory("VaasAddressScreening")
    const contract = await VaasAddressScreening.deploy()
    await contract.deployed()


    // set the vaas public key in the contract
    const vaasIlluviumSignerPublicKey = "0x8626f6940e2eb28930efb4cef49b2d1f2c9c1199"
    await contract.setVaasSignerAddress(vaasIlluviumSignerPublicKey)

    //
    // call the VAAS api
    // 
    const result = await axios.post(
        'https://rcoknqc2el.execute-api.us-east-1.amazonaws.com/illuvium-contract-firewall-demo/validate-address', 
        { "address": finalUserWallet.address }
    );
    console.log('api called, timestamp=', result.data.vaasTimestamp)
    // get the timestamp and hash signature
    vaasTimestamp = result.data.vaasTimestamp;
    vaasHashSignature = result.data.vaasHashSignature;
    var contractAddressValidation = await contract.connect(finalUserWallet).validateAddress(finalUserWallet.address, vaasTimestamp, vaasHashSignature);
    expect(contractAddressValidation).to.equal(true)
  });
});
