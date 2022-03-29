pragma solidity 0.8.7;

//["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public confirmationCount;
    struct Transactions {
        address payable to;
        uint256 value;
        uint256 confirmations;
        bool executed;
    }
    mapping(uint256 => mapping(address => bool)) public isConfirmedBy;

    Transactions[] public transactions;

    constructor(address[] memory _owners, uint256 _confirmationCount) {
        require(_owners.length > 0, "There should be atleast 1 owner");
        require(
            _confirmationCount >= 1 && _confirmationCount <= _owners.length,
            "Confirmations count value not valid"
        );
        for (uint256 i = 0; i < _owners.length; i++) {
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }
        confirmationCount = _confirmationCount;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only owner can do this action");
        _;
    }

    modifier balanceCheck(uint256 _value) {
        require(
            _value <= address(this).balance,
            "There is not eniugh balance in this contract."
        );
        _;
    }

    modifier checkTxnExecution(uint256 _txnId) {
        require(!transactions[_txnId].executed, "This txn is already executed");
        _;
    }

    event transactionCreated(uint256 _txnId);
    event transactionConfirmed(uint256 _txnId);
    event transactionConfirmationRevoked(uint256 _txnId);
    event depositeConfirmed(uint256 value);

    function createTransaction(uint256 _value, address payable _to)
        external
        onlyOwner
        balanceCheck(_value)
    {
        uint256 txnId = transactions.length;
        transactions.push(
            Transactions({
                to: _to,
                value: _value,
                confirmations: 0,
                executed: false
            })
        );
        emit transactionCreated(txnId);
    }

    function confirmTransaction(uint256 _txnId)
        external
        onlyOwner
        checkTxnExecution(_txnId)
    {
        require(
            !isConfirmedBy[_txnId][msg.sender],
            "Sender already confirmed this txn"
        );
        isConfirmedBy[_txnId][msg.sender] = true;
        transactions[_txnId].confirmations += 1;
        emit transactionConfirmed(_txnId);
    }

    function revokeTransactionConfirmation(uint256 _txnId)
        external
        onlyOwner
        checkTxnExecution(_txnId)
    {
        require(
            !isConfirmedBy[_txnId][msg.sender],
            "Sender have'nt confirmed this txn yet"
        );
        isConfirmedBy[_txnId][msg.sender] = false;
        transactions[_txnId].confirmations -= 1;
        emit transactionConfirmationRevoked(_txnId);
    }

    function approveTransaction(uint256 _txnId)
        external
        onlyOwner
        balanceCheck(transactions[_txnId].value)
        checkTxnExecution(_txnId)
    {
        require(
            transactions[_txnId].confirmations >= confirmationCount,
            "This txn is not confirmed by enough owners yet"
        );
        transactions[_txnId].to.transfer(transactions[_txnId].value * 1 ether);
        transactions[_txnId].executed = true;
    }

    function deposite() external payable {
        emit depositeConfirmed(msg.value);
    }
}
