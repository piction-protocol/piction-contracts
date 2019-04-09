const Enquirer = require('enquirer');
const SelectDeploy = require('./SelectDeploy');
var exec = require('child_process').exec;

module.exports = async () => {
  const enquirer = new Enquirer();
  const questions = [{
      type: 'radio',
      name: 'compile',
      message: 'Do you want compile?',
      choices: ['Yes', 'No']
  }]
  enquirer.register('radio', require('prompt-radio'));
  await enquirer.ask(questions)
      .then((answers) => { 
        if (answers.compile === 'Yes') {
          log(`>>>>>>>>>> [Compile] <<<<<<<<<<`);
          exec("truffle compile", function(error, stdout, stderr) {
            console.log(stdout);
            log(`-------------------------------------------------------------------`);
            SelectDeploy();
          });
        } else {
          SelectDeploy();
        }
      })
      .catch((err) => log(err));
};