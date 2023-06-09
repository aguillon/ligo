export default [
  { header: "account" },
  {
    name: "eth_getBalance",
    inputs: [
      { name: "address", type: "address" },
      { name: "blockNumber", type: "uint256" },
    ],
  },
  {
    name: "eth_getTransactionCount",
    inputs: [
      { name: "address", type: "address" },
      { name: "blockNumber", type: "uint256" },
    ],
  },
  {
    name: "eth_getCode",
    inputs: [
      { name: "address", type: "address" },
      { name: "blockNumber", type: "uint256" },
    ],
  },
  {
    name: "eth_getStorageAt",
    inputs: [
      { name: "address", type: "address" },
      { name: "position", type: "uint256" },
      { name: "blockNumber", type: "uint256" },
    ],
  },
  { divider: true },

  { header: "block" },
  { name: "eth_blockNumber", inputs: [] },
  {
    name: "eth_getBlockByHash",
    inputs: [
      { name: "blockHash", type: "bytes32" },
      { name: "transactions", type: "bool" },
    ],
  },
  {
    name: "eth_getBlockByNumber",
    inputs: [
      { name: "blockNumber", type: "uint256" },
      { name: "transactions", type: "bool" },
    ],
  },
  {
    name: "eth_getBlockTransactionCountByHash",
    inputs: [{ name: "blockHash", type: "bytes32" }],
  },
  {
    name: "eth_getBlockTransactionCountByNumber",
    inputs: [{ name: "blockNumber", type: "uint256" }],
  },
  {
    name: "eth_getTransactionByBlockHashAndIndex",
    inputs: [
      { name: "blockHash", type: "bytes32" },
      { name: "index", type: "uint256" },
    ],
  },
  {
    name: "eth_getTransactionByBlockNumberAndIndex",
    inputs: [
      { name: "blockNumber", type: "uint256" },
      { name: "index", type: "uint256" },
    ],
  },
  {
    name: "eth_getUncleCountByBlockHash",
    inputs: [{ name: "blockHash", type: "bytes32" }],
  },
  {
    name: "eth_getUncleCountByBlockNumber",
    inputs: [{ name: "blockNumber", type: "uint256" }],
  },
  {
    name: "eth_getUncleByBlockHashAndIndex",
    inputs: [
      { name: "blockHash", type: "bytes32" },
      { name: "index", type: "uint256" },
    ],
  },
  {
    name: "eth_getUncleByBlockNumberAndIndex",
    inputs: [
      { name: "blockNumber", type: "uint256" },
      { name: "index", type: "uint256" },
    ],
  },
  { divider: true },

  { header: "transaction" },
  {
    name: "eth_getTransactionByHash",
    inputs: [{ name: "hash", type: "bytes32" }],
  },
  {
    name: "eth_getTransactionReceipt",
    inputs: [{ name: "hash", type: "bytes32" }],
  },
  {
    name: "eth_sendTransaction",
    inputs: [
      {
        name: "transaction",
        type: "tuple",
        components: [
          { name: "from", type: "address" },
          { name: "to", type: "address" },
          { name: "gas", type: "uint256" },
          { name: "gasPrice", type: "uint256" },
          { name: "value", type: "uint256" },
          { name: "data", type: "bytes" },
        ],
      },
    ],
  },
  {
    name: "eth_sendRawTransaction",
    inputs: [
      {
        name: "transaction",
        type: "tuple",
        components: [{ name: "data", type: "bytes" }],
      },
    ],
  },
  {
    name: "eth_call",
    inputs: [
      {
        name: "call",
        type: "transaction",
        components: [
          { name: "from", type: "address" },
          { name: "to", type: "address" },
          { name: "gas", type: "uint256" },
          { name: "gasPrice", type: "uint256" },
          { name: "value", type: "uint256" },
          { name: "data", type: "bytes" },
        ],
      },
      { name: "blockNumber", type: "uint256" },
    ],
  },
  {
    name: "eth_estimateGas",
    inputs: [
      {
        name: "transaction",
        type: "tuple",
        components: [
          { name: "from", type: "address" },
          { name: "to", type: "address" },
          { name: "gas", type: "uint256" },
          { name: "gasPrice", type: "uint256" },
          { name: "value", type: "uint256" },
          { name: "data", type: "bytes" },
        ],
      },
      { name: "blockNumber", type: "uint256" },
    ],
  },
  {
    name: "eth_getLogs",
    inputs: [
      {
        name: "filter",
        type: "tuple",
        components: [
          { name: "fromBlock", type: "uint256" },
          { name: "toBlock", type: "uint256" },
          { name: "address", type: "address" },
          { name: "topic", type: "bytes[]" },
          // { name: 'blockhash', type: 'bytes' },
        ],
      },
    ],
  },
  { divider: true },

  { header: "info" },
  { name: "eth_gasPrice", inputs: [] },
  {
    name: "eth_feeHistory",
    inputs: [
      { name: "blockCount", type: "uint256" },
      { name: "newestBlock", type: "uint256" },
      { name: "rewardPercentiles", type: "uint256[]" },
    ],
  },
  { name: "eth_protocolVersion", inputs: [] },
  { name: "eth_coinbase", inputs: [] },
  { name: "eth_mining", inputs: [] },
  { name: "eth_accounts", inputs: [] },
  { divider: true },

  { header: "web3" },
  { name: "web3_clientVersion", inputs: [] },
  { name: "web3_sha3", inputs: [{ name: "data", type: "bytes" }] },
  { divider: true },

  { header: "net" },
  { name: "net_version", inputs: [] },
  { name: "net_listening", inputs: [] },
  { name: "net_peerCount", inputs: [] },
  { divider: true },

  { header: "compiler" },
  { name: "eth_getCompilers", inputs: [] },
  { name: "eth_compileSolidity", inputs: [{ name: "source", type: "string" }] },
  { name: "eth_compileLLL", inputs: [{ name: "source", type: "string" }] },
  { name: "eth_compileSerpent", inputs: [{ name: "source", type: "string" }] },
];
