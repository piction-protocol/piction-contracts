const Enquirer = require('enquirer');

module.exports = async (stage) => {
    const enquirer = new Enquirer();
    const questions = [{
        type: 'radio',
        name: 'result',
        message: 'Which contract would you like to distribute?',
        choices: ['DeployAll', 'PictionNetwork', 'PXL', 'AccountManager', 'ProjectManager', 'ContentsRevenue', 'ContentsDistributor', 'UserAdoptionPool', 'EcosystemFund', 'CleanEnv', 'Proxy', 'LogStorage', 'ProxyBC', 'LogStorageBC']
    }];
    enquirer.register('radio', require('prompt-radio'));
    enquirer.ask(questions)
        .then((answers) => require(`./${answers.result}.js`)(stage))
        .catch((err) => log(err));
};