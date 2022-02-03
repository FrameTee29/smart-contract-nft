// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File contracts/KAP20/interfaces/IKAP20.sol

pragma solidity ^0.8.0;

interface IKAP20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}


// File contracts/KAP20/interfaces/IKAP20Metadata.sol

pragma solidity ^0.8.0;
interface IKAP20Metadata is IKAP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


// File contracts/KAP20/abstracts/KAP20.sol

pragma solidity ^0.8.0;
abstract contract KAP20 is IKAP20, IKAP20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances; // owner => spender => amount

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return _balances[owner];
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool success)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool success)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return _allowances[owner][spender];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool success) {
        if (from != msg.sender) {
            uint256 allowanceAmount = _allowances[from][msg.sender];
            require(
                amount <= allowanceAmount,
                "transfer amount exceeds allowance"
            );
            _approve(from, msg.sender, allowanceAmount - amount);
        }

        _transfer(from, to, amount);
        return true;
    }

    //=====> Private Function <=====

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "transfer from zero address");
        require(to != address(0), "transfer to zero address");
        require(amount <= balanceOf(from), "transfer amount exceeds balance");

        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "transfer owner zero address");
        require(spender != address(0), "transfer spender zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "mint to zero address");

        _balances[to] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "burn from zero address");
        require(amount <= balanceOf(from), "burn from zero address");

        _balances[from] -= amount;
        _totalSupply -= amount;

        emit Transfer(from, address(0), amount);
    }
}


// File contracts/Bullet.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract Bullet is KAP20 {
    constructor(string memory name_, string memory symbol_)
        KAP20(name_, symbol_)
    {}

    function deposit(uint256 amount) public payable {
        require(amount > 0, "amount is zero");

        _mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(
            amount > 0 && amount <= balanceOf(msg.sender),
            "withdraw amount exceeds balance"
        );

        // payable(msg.sender).transfer(amount);
        _burn(msg.sender, amount);
    }
}
