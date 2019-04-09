const fs = require('fs');
const replace = require('replace-in-file');

module.exports = async () => {
    log(`>>>>>>>>>> [Clean Env File] <<<<<<<<<<`);

    process.env.ACCOUNTSMANAGER_ADDRESS = '';
    process.env.CONTENTSMANAGER_ADDRESS = '';
    process.env.PICTIONNETWORK_ADDRESS = '';

    try {
        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /ACCOUNTSMANAGER_ADDRESS=.*/g,
            to: `ACCOUNTSMANAGER_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /CONTENTSMANAGER_ADDRESS=.*/g,
            to: `CONTENTSMANAGER_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /PICTIONNETWORK_ADDRESS=.*/g,
            to: `PICTIONNETWORK_ADDRESS=`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    }  

    info(`Clean Completed.`);
    log(`-------------------------------------------------------------------`);
};