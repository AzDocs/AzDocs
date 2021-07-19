[[_TOC_]]

# Setup Azure DevOps & GIT
We are using a more-or-less complex GIT setup to fulfil our needs. The generic library you are watching right now should be sharable between companies at all times. This means that no company related data/rules should be implemented in this boilerplate. However, you probably have scripts & documentation which actually does contain logics or information of/for your company. To deal with this, we've created a 2-tier GIT repo. We created a company specific repo with this generic repo, in it, as a GIT submodule. This implies that commiting, pulling & pushing gets a little more complicated. To help you out, this paragraph should tell you how the workflow should work.

So in short:
 - Generic scripts which can be shared between companies --> Upstream/Generic repository
 - Company specific scripts which can't/shouldn't be shared --> Your company repository

## Create a new Azure DevOps Project
We recommend creating an `Azure Documentation` teamproject in your Azure DevOps instance.

1. On the main page click the New Project button in the top right corner.

![Main page](../../../wiki_images/azdo_create_new_teamproject_1.png)

2. Fill in the name of the new project. We use `Azure Documentation` for this.

![Creating the team project](../../../wiki_images/azdo_create_new_teamproject_2.png)

3. Create the project and you will be sent to it's landing page.

![Created the team project](../../../wiki_images/azdo_create_new_teamproject_7.png)

## Mirroring the upstream repo to your own Azure DevOps instance
First of all you need to mirror [the upstream github repo](https://github.com/RobHofmann/Azure.PlatformProvisioning) to your own Azure DevOps instance as a working repo. To do this, follow these steps:

1. Go to the `Repos` section of your TeamProject (in our case we created the teamproject Azure Documentation according to the [Create a new Azure DevOps Project](#create-a-new-azure-devops-project) section of this document).

2. Create a new repository.

![Create new repository](../../../wiki_images/azdo_create_new_teamproject_3.png)

3. For the name fill in `Upstream.Azure.PlatformProvisioning`. Make sure to disable the `Add a README` option and put `Add a .gitignore` to `none`. Hit the `Create` button.

![Create new repository](../../../wiki_images/azdo_create_new_teamproject_6.png)

4. In the repo screen, make sure to have your `Upstream.Azure.PlatformProvisioning` repo selected. Hit the `Import` button

![Mirror repo](../../../wiki_images/azdo_create_new_teamproject_8.png)

5. Import the `upstream` git repo from GitHub (Enter: https://github.com/RobHofmann/Azure.PlatformProvisioning.git).

![Mirror repo](../../../wiki_images/azdo_create_new_teamproject_4.png)

6. Give it a second to import the repo.

![Mirror repo](../../../wiki_images/azdo_create_new_teamproject_5.png)

7. You will now have an imported repository.

![Mirror repo](../../../wiki_images/azdo_create_new_teamproject_9.png)

## Expose the docs as a wiki in your DevOps project
This project also includes documentation next to the scripts. Even better: the document you are reading right now is inside this documentation :). You can publish these docs as a Wiki inside your own Azure DevOps teamproject. Here's how to do it:

1. Go to your teamproject and navigate to `Overview` --> `Wiki`.

![Expose your Docs as Wiki](../../../wiki_images/azdo_publish_docs_as_wiki_1.png)

2. Next, click the `Publish code as Wiki` button.

![Expose your Docs as Wiki](../../../wiki_images/azdo_publish_docs_as_wiki_2.png)

3. Fill in the wiki information as shown on the screenshot below and hit the `Publish` button. The wiki is inside the `Generic repository`.

![Expose your Docs as Wiki](../../../wiki_images/azdo_publish_docs_as_wiki_3.png)

4. You will be redirected to your freshly exposed Wiki which you can now navigate!

![Expose your Docs as Wiki](../../../wiki_images/azdo_publish_docs_as_wiki_4.png)

## Recommended GIT structure / Company specific repository
As explained in [Setup Azure DevOps & GIT](#setup-azure-devops-%26-git) we have a setup with a company repo which holds this generic repo. We've done this to create 1 starting point for you and your colleagues to work with both company specific wiki's & scripts as well as the generic wiki & scripts. This is how the repository looks:

![Repository structure](../../../wiki_images/git_howto_repo_structure.png)

To create this repository the same way, follow these steps:

1. Create the new company specific repository next to the generic repo you already made in [Mirroring the upstream repo to your own Azure DevOps instance](#mirroring-the-upstream-repo-to-your-own-azure-devops-instance).

![Create company repo](../../../wiki_images/git_create_company_repo_1.png)

2. Fill in the information of your company repo (the name in the screenshot is fictional) and click on the `Create` button.

![Create company repo](../../../wiki_images/git_create_company_repo_2.png)

3. Get the company cloning address by clicking the `Clone` button in your freshly created repository.

![Create company repo](../../../wiki_images/git_create_company_repo_3.png)

4. Copy the clone address by clicking the copy button.

![Create company repo](../../../wiki_images/git_create_company_repo_4.png)

5. Open the terminal of your choice (We recommend using Windows Terminal) and navigate to the folder where you want to checkout this repo. Now clone the repo, CD into it, add the submodule & commit & push it back to the server using these commando's (make sure to substitute the variables before running the commands):

```batch
git clone <repo url>
cd <repo folder>
git submodule add <upstream repo url> Azure.PlatformProvisioning
git commit -a -m "Added sub repo"
git push origin main
```
> The upstream repo url is the URL made in the [Mirroring the upstream repo to your own Azure DevOps instance](#mirroring-the-upstream-repo-to-your-own-azure-devops-instance) step.

Congratulations. You now have created a company specific repository with the Generic repository as its submodule!

## Checking out the company specific repository on a new computer
Since your company specific repository has a submodule to the generic AzDocs, you need to do something special to check the whole structure out. You need to tell GIT to also clone the submodules on cloning your company specific repo. So instead of the usual:

`git clone <company specific repo url>`

you need to do:

`git clone --recurse-submodules <company specific repo url>`

> The URL of this repo is the URL to the repo created in this step: [Recommended GIT structure / Company specific repository](#recommended-git-structure-%2F-company-specific-repository)

Et voila! your full repository (or actually repositories) is/are now cloned!

## Working with this setup & GIT
Whenever you work with submodules and you edit something in these submodules (in this case the upstream repo), you need to update the reference in the company specific repo to the new commit of this generic (your copy of the upstream) repo. This is a pretty straightforward process, but it can be a little hard to figure out on your own.

First of all, lets assume you are using Visual Studio Code. This example will make use of VsCode so that we can make it visual:

1. Make your change in the generic repo. Let's assume you already have done this. In this example we changed the `Azure.md` file.

2. In VsCode when you opened the company specific repo with the submodule as a folder (File --> Open Folder), 

![Commit changes](../../../wiki_images/commit_changes_1.png)

3. Under the `Source Control` tab you will see two repositories. Commit & Push the generic repo content (in our case the `Azure.md` file.). This is the bottom one in the following screenshot.

![Commit changes](../../../wiki_images/commit_changes_2.png)

4. In the top repo you will see that the submodule file was changed (in the screenshot the file is called `Azure.PlatformProvisioning`). If you click on this change, you will see the following:

![Commit changes](../../../wiki_images/commit_changes_3.png)

5. In the screenshot you see that the subproject commit id has changed. This is to reference the new version (commit) of your generic repository. Commit & Push this file to update your company specific repo. At this point, your automatic build-pipeline will start to run.

6. After the build-pipeline is done, you will have the new version of the AzDocs at your disposal.

## How to keep your repositories in sync with upstream
*For the next procedure you will need an account at GitHub. Make sure to have this before continuing. You can create a GitHub account [here](https://github.com/join).*

The generic repo will have 2 remote's if you also want to contribute to this project or get new updates from this project. So after mirroring [the upstream github repo](https://github.com/RobHofmann/Azure.PlatformProvisioning) to your own Azure DevOps instance, you want to clone the repository to your local machine.

> NOTE: Next to the working company repository with the generic repository inside (as explained in [the GIT paragraph](#git)) you daily use, we tend to keep the upstream in a separate folder on our computer aswell for syncing our origin with the upstream repo.

First clone the repo to your local disk with:

`git clone <upstream repo url>`

> The upstream repo url is the URL made in the [Mirroring the upstream repo to your own Azure DevOps instance](#mirroring-the-upstream-repo-to-your-own-azure-devops-instance) step.

After doing this you enter the freshly created repo folder and use this command to add the upstream remote to your local repo:

`git remote add upstream https://github.com/RobHofmann/Azure.PlatformProvisioning.git`

Doing so will give you two remotes: `origin` & `upstream`.

### Pulling new changes from upstream (Github) to your origin repo
*Make sure you followed the information from [How to keep your repositories in sync with upstream](#how-to-keep-your-repositories-in-sync-with-upstream) first.*

For this example lets assume that some work has been done by other companies and you want the latest & greatest changes for your company. Since our philosophy is that `upstream` should always be able to merge to `origin` we pull directly into our `origin/main` branch to avoid squash commits over and over between `upstream` & `origin`. Follow these steps to get the latest from `upstream` to your `origin`:

> First navigate to the cloned upstream repo (the repo made in the [Mirroring the upstream repo to your own Azure DevOps instance](#mirroring-the-upstream-repo-to-your-own-azure-devops-instance) step). Then follow these steps:

```batch
git checkout main
git pull upstream main
git push origin main
```

![Updated main branch](../../../wiki_images/git_how_to_keep_repos_in_sync_with_upstream_5.png)

Your repository is now up to date.

### Commit the work you've done to the upstream (GitHub) repo
*Make sure you followed the information from [How to keep your repositories in sync with upstream](#how-to-keep-your-repositories-in-sync-with-upstream) first.*

Let's assume you've done some work on your `origin` and at some point in time you want to sync this back to the `upstream`. We do this by creating a new branch and pushing it to the upstream. We need to make sure we use the latest version of main to create our PR Branch from:

> First navigate to the cloned upstream repo (the repo made in the [Mirroring the upstream repo to your own Azure DevOps instance](#mirroring-the-upstream-repo-to-your-own-azure-devops-instance) step). Then follow these steps:

```batch
git checkout main
git pull origin main
git checkout -b 20210426
git push upstream 20210426
```

This will create a new branch in the upstream repo. After this you can [create a PR](https://github.com/RobHofmann/Azure.PlatformProvisioning/compare) on github. Select the branch you just created from the "compare" list.

![Select the compare branch](../../../wiki_images/git_how_to_keep_repos_in_sync_with_upstream_1.png)

Now confirm the selected branch by clicking the green `Create pull request` button.

![Confirm the branch selection](../../../wiki_images/git_how_to_keep_repos_in_sync_with_upstream_2.png)

Finally enter the name of your PR (I recommend naming it the same as the branch you created).

![Create a PR on GitHub](../../../wiki_images/git_how_to_keep_repos_in_sync_with_upstream_3.png)

Done! From here multiple people will review this PR. Eventually the PR will be accepted or rejected based on the feedback & discussion. Make sure to reply to questions being asked & actively participate in the discussion revolving your PR.

![Accepted & Merged PR](../../../wiki_images/git_how_to_keep_repos_in_sync_with_upstream_4.png)

*A merged pullrequest in the `upstream/main` branch*
