const CleanEnv = require('./CleanEnv');
const PictionNetwork = require('./PictionNetwork');

module.exports = async () => {
    await CleanEnv();

    await PictionNetwork();
};