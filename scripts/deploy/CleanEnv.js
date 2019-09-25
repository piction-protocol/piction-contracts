const fs = require('fs');
const replace = require('replace-in-file');

module.exports = async () => {
    log(`>>>>>>>>>> [Clean Env File] <<<<<<<<<<`);

    process.env.PXL_ADDRESS = '';
    process.env.PICTIONNETWORK_ADDRESS = '';
    process.env.ACCOUNTSSTORAGE_ADDRESS = '';
    process.env.PROJECTSTORAGE_ADDRESS = '';
    process.env.RELATIONSTORAGE_ADDRESS = '';
    process.env.ACCOUNTSMANAGER_ADDRESS = '';
    process.env.PROJECTMANAGER_ADDRESS = '';
    process.env.POSTMANAGER_ADDRESS = '';
    process.env.CONTENTSREVENUE_ADDRESS = '';
    process.env.CONTENTSDISTRIBUTOR_ADDRESS = '';
    process.env.USERADOPTIONPOOL_ADDRESS = '';
    process.env.ECOSYSTEMFUND_ADDRESS = '';

    try {
        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /PXL_ADDRESS=.*/g,
            to: `PXL_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /PICTIONNETWORK_ADDRESS=.*/g,
            to: `PICTIONNETWORK_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /ACCOUNTSSTORAGE_ADDRESS=.*/g,
            to: `ACCOUNTSSTORAGE_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /PROJECTSTORAGE_ADDRESS=.*/g,
            to: `PROJECTSTORAGE_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /RELATIONSTORAGE_ADDRESS=.*/g,
            to: `RELATIONSTORAGE_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /ACCOUNTSMANAGER_ADDRESS=.*/g,
            to: `ACCOUNTSMANAGER_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /PROJECTMANAGER_ADDRESS=.*/g,
            to: `PROJECTMANAGER_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /POSTMANAGER_ADDRESS=.*/g,
            to: `POSTMANAGER_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /CONTENTSREVENUE_ADDRESS=.*/g,
            to: `CONTENTSREVENUE_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /CONTENTSDISTRIBUTOR_ADDRESS=.*/g,
            to: `CONTENTSDISTRIBUTOR_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /USERADOPTIONPOOL_ADDRESS=.*/g,
            to: `USERADOPTIONPOOL_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /ECOSYSTEMFUND_ADDRESS=.*/g,
            to: `ECOSYSTEMFUND_ADDRESS=`
        });

        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /PROXY_ADDRESS=.*/g,
            to: `PROXY_ADDRESS=`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    }  

    info(`Clean Completed.`);
    log(`-------------------------------------------------------------------`);
};