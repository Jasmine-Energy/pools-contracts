// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;

library OrderedSet {

    using OrderedSet for OrderedTokenSet;

    struct OrderedTokenSet {
        /// @dev Mapping of index to next token in ascending order's index
        mapping(uint256 => uint256) _tokenNeighbours;
        // @dev Mapping of token to index in tokens array
        mapping(uint256 => uint256) _indexes;
        uint256[] _tokens;
    }

    uint256 private constant GUARD = type(uint256).max;

    function initialize(OrderedTokenSet storage set) internal {
        set._tokenNeighbours[GUARD] = GUARD;
    }

    function _atInternalIndex(OrderedTokenSet storage set, uint256 index) private view returns (uint256) {
        if (index >= set._tokens.length) {
            return GUARD;
        }
        return set._tokens[set._indexes[index]];
    }

    function at(OrderedTokenSet storage set, uint256 index) internal view returns (uint256) {
        // TODO: Rewrite to ordered index
        if (index >= set._tokens.length) {
            return GUARD;
        }
        return set._tokens[set._indexes[index]];
    }

    function add(OrderedTokenSet storage set, uint256 token) internal {
        if (set.contains(token)) {
            return;
        }

        // 1. Add to tokens array and indexes mapping
        set._tokens.push(token);
        uint256 tokenIndex = set._tokens.length;
        set._indexes[token] = tokenIndex;

        // 2. Find insertion index
        uint256 insertionIndex = _findInsertionIndex(set, token);

        // 3. If insertion index is 0, set token as new head
        if (insertionIndex == 0) {
            set._tokenNeighbours[GUARD] = tokenIndex;
        } else {
            uint256 previousValue = set._tokenNeighbours[insertionIndex - 1];
            uint256 nextValue = set._tokenNeighbours[insertionIndex];

            // 4. Set token's neighbours
            set._tokenNeighbours[previousValue] = tokenIndex;
            set._tokenNeighbours[tokenIndex] = nextValue;
        }
    }

    function contains(OrderedTokenSet storage set, uint256 token) internal view returns (bool) {
        return set._indexes[token] != 0;
    }

    function _verifyIndex(OrderedTokenSet storage set, uint256 previousValue, uint256 newValue, uint256 nextValue)
      private view
      returns(bool isValid)
    {
      return (previousValue == GUARD || set.at(previousValue) >= newValue) && 
             (nextValue == GUARD || newValue > set.at(nextValue));
    }

    function _findInsertionIndex(OrderedTokenSet storage set, uint256 token) private view returns (uint256 index) {
        if (set._tokens.length == 0) {
            return 0;
        }
        // TODO: Runs in O(n) but can be done in O(log(n)) with a binary search
        index = GUARD;
        uint256 nextIndex = set._tokenNeighbours[GUARD];
        while (nextIndex != GUARD && _atInternalIndex(set, nextIndex) < token) {
            index = nextIndex;
            nextIndex = set._tokenNeighbours[nextIndex];
        }
        return index;        
    }
}
