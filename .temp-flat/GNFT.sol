// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File contracts/KAP721/interfaces/IKAP721.sol

pragma solidity ^0.8.0;

interface IKAP721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function setApprovalForAll(address operator, bool approved) external ;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function approve(address to, uint256 tokenId) external ;
    function getApproved(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external ;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external ;
    function safeTransferFrom(address from, address to, uint256 tokenId) external ;
}


// File contracts/KAP721/interfaces/IKAP721Metadata.sol

pragma solidity ^0.8.0;

interface IKAP721Metadata  {
    function name() external view returns (string memory );
    function symbol() external view returns (string memory );
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


// File contracts/KAP721/interfaces/IKAP721Enumerable.sol

pragma solidity ^0.8.0;

interface IKAP721Enumerable  {
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}


// File contracts/KAP721/interfaces/IKAP721TokenReceiver.sol

pragma solidity ^0.8.0;

interface IKAP721TokenReceiver {
    function onKAP721Received(address operator, address from, uint256 tokenId, bytes memory _data) external returns(bytes4);
}


// File contracts/KAP165/interfaces/IKAP165.sol

pragma solidity ^0.8.0;

interface IKAP165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File contracts/KAP1155/interfaces/IKAP1155Metadata_URI.sol

pragma solidity ^0.8.0;

interface IKAP1155Metadata_URI {
    function uri(uint256 tokenId) external view returns (string memory);
}


// File contracts/KAP721/abstracts/KAP721.sol

pragma solidity ^0.8.0;
abstract contract KAP721 is
    IKAP165,
    IKAP721,
    IKAP721Metadata,
    IKAP1155Metadata_URI,
    IKAP721Enumerable
{
    mapping(address => uint256) _balances; // counter my items; owner => balance;
    mapping(uint256 => address) _owners; // tokenId => owner;
    mapping(address => mapping(address => bool)) _operatorApprovals; //owner => (operator => allow)
    mapping(uint256 => address) _tokenApprovals; //tokenId => operator ( 1 token / 1 address )

    string _name;
    string _symbol;
    mapping(uint256 => string) _tokenURIs; // tokenId => uri

    //All Enumeration
    uint256[] _allTokens;
    mapping(uint256 => uint256) _allTokensIndex; // tokenId => index

    //Owner Enumeration
    mapping(address => mapping(uint256 => uint256)) _omwedTokens; // owener => (index=>tokenId)
    mapping(uint256 => uint256) _ownedTokensIndex; // tokenId => index

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

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return _tokenURIs[tokenId];
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IKAP165).interfaceId ||
            interfaceId == type(IKAP721).interfaceId ||
            interfaceId == type(IKAP721Metadata).interfaceId ||
            interfaceId == type(IKAP1155Metadata_URI).interfaceId ||
            interfaceId == type(IKAP721Enumerable).interfaceId;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "owner is zero address");

        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "token is not exists");
        return owner;
    }

    function setApprovalForAll(address operator, bool approved)
        public
        override
    {
        require(msg.sender != operator, "approval status for self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "approval status for self");
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "caller is not token owner or approval for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        override
        returns (address)
    {
        require(_owners[tokenId] != address(0), "token is not exists");
        return _tokenApprovals[tokenId];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(from != address(0), "transfer from zero address");
        require(to != address(0), "transfer to zero address");

        address owner = ownerOf(tokenId);
        require(owner == from, "transfer from is not token owner");
        require(
            msg.sender == owner ||
                msg.sender == getApproved(tokenId) ||
                isApprovedForAll(owner, msg.sender),
            "caller is not token owner or approval for all"
        );
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _removeTokenToOwnerEnumeration(from, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override {
        transferFrom(from, to, tokenId);

        require(
            _checkOnKap721Received(from, to, tokenId, data),
            "transfer to non KAP72Receiver implementer"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        transferFrom(from, to, tokenId);

        require(
            _checkOnKap721Received(from, to, tokenId, ""),
            "transfer to non KAP72Receiver implementer"
        );
    }

    function totalSupply() public view override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index)
        public
        view
        override
        returns (uint256)
    {
        require(index < _allTokens.length, "index out of bounds");
        return _allTokens[index];
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        override
        returns (uint256)
    {
        require(index < _balances[owner], "index out of bounds");
        return _omwedTokens[owner][index];
    }

    // =====> Private Or Internal Function <=====
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        address owner = ownerOf(tokenId);
        emit Approval(owner, to, tokenId);
    }

    function _checkOnKap721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length <= 0) return true;

        IKAP721TokenReceiver receiver = IKAP721TokenReceiver(to);
        try receiver.onKAP721Received(msg.sender, from, tokenId, data) returns (
            bytes4 interfaceId
        ) {
            return interfaceId == type(IKAP721TokenReceiver).interfaceId;
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("transfer to non KAP72Receiver implementer");
        }
    }

    function _mint(
        address to,
        uint256 tokenId,
        string memory uri_
    ) internal {
        require(to != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = uri_;

        emit Transfer(address(0), to, tokenId);

        _addTokenToAllEnumeration(tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);

        require(
            msg.sender == ownerOf(tokenId) ||
                msg.sender == getApproved(tokenId) ||
                isApprovedForAll(owner, msg.sender),
            "caller is not owner or approved"
        );
        _approve(address(0), tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];
        delete _tokenURIs[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _removeTokenToAllEnumeration(tokenId);
        _removeTokenToOwnerEnumeration(owner, tokenId);
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        string memory uri_,
        bytes memory data
    ) internal {
        _mint(to, tokenId, uri_);

        require(
            _checkOnKap721Received(address(0), to, tokenId, data),
            "mint to non KAP721Receiver implementer "
        );
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        string memory uri_
    ) internal {
        _safeMint(to, tokenId, uri_, "");
    }

    //All Enumeration
    function _addTokenToAllEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
        _allTokensIndex[tokenId] = _allTokens.length - 1;
    }

    function _removeTokenToAllEnumeration(uint256 tokenId) private {
        uint256 index = _allTokensIndex[tokenId];
        uint256 indexLast = _allTokens.length - 1;

        if (index < indexLast) {
            uint256 idLast = _allTokens[indexLast];
            _allTokens[index] = idLast;
            _allTokensIndex[idLast] = index;
        }

        _allTokens.pop();
        delete _allTokensIndex[tokenId];
    }

    //Owener Enumeration
    function _addTokenToOwnerEnumeration(address owner, uint256 tokenId)
        private
    {
        uint256 index = _balances[owner] - 1;
        _omwedTokens[owner][index] = tokenId;
        _ownedTokensIndex[tokenId] = index;
    }

    function _removeTokenToOwnerEnumeration(address owner, uint256 tokenId)
        private
    {
        uint256 index = _ownedTokensIndex[tokenId];
        uint256 indexLast = _balances[owner];

        if (index < indexLast) {
            uint256 idLast = _omwedTokens[owner][indexLast];
            _omwedTokens[owner][index] = idLast;
            _ownedTokensIndex[idLast] = index;
        }

        delete _omwedTokens[owner][indexLast];
        delete _ownedTokensIndex[tokenId];
    }
}


// File contracts/GNFT.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract GNFT is KAP721 {
    
    constructor() KAP721("Frame NFT","FNFT"){}

    function create(uint tokenId,string memory uri ) public{
        _mint(msg.sender,tokenId,uri);
    }

    function burn(uint tokenId) public {
        _burn(tokenId);
    }
}
