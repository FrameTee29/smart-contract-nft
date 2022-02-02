// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../KAP165/interfaces/IKAP165.sol";
import "../interfaces/IKAP1155.sol";
import "../interfaces/IKAP1155Receiver.sol";
import "../interfaces/IKAP1155MetadataURI.sol";

abstract contract KAP1155 is IKAP165, IKAP1155, IKAP1155MetadataURI {
    mapping(uint256 => mapping(address => uint256)) private _balances; // tokenId => (owner => balance)
    mapping(address => mapping(address => bool)) private _operatorApprovals; // owner => (operator => allow)

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public override pure returns (bool) {
        return interfaceId == type(IKAP1155).interfaceId 
            || interfaceId == type(IKAP1155MetadataURI).interfaceId;
    }

    function uri(uint256) public override view returns (string memory) {
        return _uri;
    }

    function balanceOf(address account, uint256 id) public override view returns (uint256) {
        require(account != address(0), "KAP1155: balance query for the zero address");
        
        return _balances[id][account];
    }

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) public override view returns (uint256[] memory) {
        require(accounts.length == ids.length, "KAP1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public override {
        _setApprovalForAll(msg.sender ,operator, approved);
    }

    function isApprovedForAll(address account, address operator) public override view returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data ) public override {
        require(from == msg.sender || isApprovedForAll(from, msg.sender),"KAP1155: caller is not owner nor approved");
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) public override {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "KAP1155: transfer caller is not owner nor approved");
       
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }


    function _setURI(string memory uri_) internal virtual {
        _uri = uri_;
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "KAP1155: setting approval status for self");

        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(to != address(0), "KAP1155: transfer to the zero address");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "KAP1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(ids.length == amounts.length, "KAP1155: ids and amounts length mismatch");
        require(to != address(0), "KAP1155: transfer to the zero address");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "KAP1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(address operator, address from, address to, uint256 id, uint256 amount, bytes memory data) private returns (bool) {
        if (to.code.length <= 0) return true;

        IKAP1155Receiver receiver = IKAP1155Receiver(to);
        try receiver.onKAP1155Received(operator, from, id, amount, data) returns (bytes4 interfaceId) {
            return interfaceId == type(IKAP1155Receiver).interfaceId;
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("KAP1155: transfer to non KAP1155Receiver implementer");
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) private returns (bool) {
        if (to.code.length <= 0) return true;

        IKAP1155Receiver receiver = IKAP1155Receiver(to);
        try receiver.onKAP1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 interfaceId) {
            return interfaceId == type(IKAP1155Receiver).interfaceId;
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("KAP1155: transder to non KAP1155Receiver implementer");
        }
    }

    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(to != address(0), "KAP1155: mint to the zero address");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "KAP1155: mint to the zero address");
        require(ids.length == amounts.length, "KAP1155: ids and amounts length mismatch");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        require(from != address(0), "KAP1155: burn form the zero address");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "KAP1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(from != address(0), "KAP1155: burn from the zero address");
        require(ids.length == amounts.length, "KAP1155: ids and amounts length mismatch");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "KAP1155: burn amount exceed balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;
        
        return array;
    }
}