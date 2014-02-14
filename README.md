Escc.EastSussexGovUK.AzureDeployment
====================================

The East Sussex County Council website is hosted on [Azure Websites](www.windowsazure.com) and deployed using git.

Each application on the website has a separate git repository, but each Azure Website has a single git repository, so we have to combine our projects into a single git repository for deployment. We do this using [subtree merging](http://typecastexception.com/post/2013/03/16/Managing-Nested-Libraries-Using-the-GIT-Subtree-Merge-Workflow.aspx).

We then push the repository to Azure, where it is deployed by [Kudu](https://github.com/projectkudu/kudu). By default Kudu deploys only the first project it finds, so we use a [custom deployment script](http://blog.amitapple.com/post/38419111245/azurewebsitecustomdeploymentpart3) to deploy each project to a specific folder.

Our custom deployment script:

* [runs unit tests before deployment](http://channel9.msdn.com/Shows/Windows-Azure-Friday/Custom-Web-Site-Deployment-Scripts-with-Kudu-with-David-Ebbo) using [NUnit](http://www.nunit.org/)
* manages dependencies using [NuGet package restore](http://docs.nuget.org/docs/reference/package-restore)
* signs assemblies using MSBuild and XSL to point to our strong name key
* manages secrets using [web.config transforms](http://msdn.microsoft.com/en-us/library/dd465326.aspx)
* encrypts `appSettings` and `connectionStrings` in `web.config` using [aspnet_regiis](http://msdn.microsoft.com/en-us/library/ff647398.aspx).

### Strong named assemblies

We give some of our assemblies a strong name, but the path to the strong name key file needs to be different on Azure. We upload our key file to a directory on Azure and put the path into a `DEPLOYMENT_STRONG_NAME_KEY` app setting on the Configure page in the management portal for the Azure Website, so that the Kudu deployment script can find it.

### Configuration settings

For each `web.config` file we exclude it from our git repository, and instead commit a `web.config.example` file with secrets removed. This file typically needs to be different in the live environment, so we upload a [web.config transform](http://msdn.microsoft.com/en-us/library/dd465326.aspx) on to a directory on Azure.

We then put the path to that directory into a `DEPLOYMENT_CONFIG_TRANSFORMS` app setting on the Configure page in the management portal for the Azure Website, so that the Kudu deployment script can find it.

Set up your deployment repository
---------------------------------

Clone this repository, then open a command line in a new, empty directory where you want to create the deployment repository:

`<path to this repository>\SetupDeploymentRepo <git base URL>`

`<git base url>` is a URL such as `https://github.com/east-sussex-county-council/` to which we can add a project name to get a full repository URL.

This will create a new git repository which includes every application on the East Sussex County Council website. You can then set up the Azure Website as a remote for that repository and push to it.

Update your deployment repository
---------------------------------

Open a command line at the root of your deployment repository and run the following command:

`<path to this repository>\UpdateAll <git base URL>`

or, if you're sure only one application has changed, you can run this command:

`<path to this repository>\AddOrUpdateApp <git base URL> <git repo name>`

You can then push the deployment repository to Azure.

Note that you can't run the script from the copy of `Escc.EastSussexGovUK.AzureDeployment` which exists inside your deployment repository, because the process involves switching to branches where those scripts are not available.

### A shortcut

You can make it easier to update your repository by creating a batch file somewhere in your path with the following line. Replace `<path to this repository>` and `<git base URL>` with the correct values for your environment.

`@<path to this repository>\UpdateAll <git base URL>`

You can then simply type `UpdateAll` in the root directory of your deployment repository.


Deploy a new application
------------------------

If you've created a new application for the website, you need to modify `UpdateAllPart2.cmd` and `AzureKuduApplications.cmd` to include your application repository.

Commit and push the updated scripts, then follow the steps under 'Update your deployment repository'.

Delete an obsolete application
------------------------------

Follow these steps to completely remove an application from the website:

1.	Remove references to the application from `AzureKuduApplications.cmd` in this repository, and move it from the 'Add or update' to the 'Delete' section of `UpdateAllPart2.cmd`. Commit and push your changes.
2.	Update your deployment repository using `UpdateAll` as described in 'Update your deployment repository' above.
3.	Use FTP to connect to Azure and delete the application folder.
4.	Delete any related resources such as databases and storage containers.
5.	On the Configure tab in the Azure Portal, remove any application settings, connection strings, virtual applications and directories associated with the application.
6.	Set up 301 redirects to replacement content if appropriate.