
module.exports = {
  networks: {
    development: {
        host: "127.0.0.1",
        port: 8545,
        network_id: "*" // Match any network id
    },        
    baobab: {
        host: 'http://52.78.136.229',
        port: 8551,
        from: '', // enter your publickey
        network_id: '1001', // Baobab network id
        gas: 8000000, 
        gasPrice: 25000000000
    }
  }
};
