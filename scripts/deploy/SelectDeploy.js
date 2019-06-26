const Enquirer = require('enquirer');

module.exports = async () => {
    const enquirer = new Enquirer();
    const questions = [{
        type: 'radio',
        name: 'result',
        message: 'Which contract would you like to distribute?',
        choices: ['DeployAll', 'DeployBaobab', 'PictionNetwork', 'PXL', 'AccountsStorage', 'ProjectStorage', 'RelationStorage', 'AccountsManager', 'ProjectManager', 'PostManager', 'ContentsRevenue', 'ContentsDistributor', 'UserAdoptionPool', 'EcosystemFund', 'CleanEnv']
    }];
    enquirer.register('radio', require('prompt-radio'));
    enquirer.ask(questions)
        .then((answers) => require(`./${answers.result}.js`)())
        .catch((err) => log(err));
};