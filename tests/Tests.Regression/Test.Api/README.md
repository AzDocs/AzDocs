# Introduction 
This solution contains code for a website and function app for testing the scripts to create Azure resources. 
You can also test the creation of a number of the resources with the TestApiTest project.
 

# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
2.	Software dependencies
3.	Latest releases
4.	API references

# Build and Test
Running the tests from the testproject can be run locally with a .runsettings or using the test.runsettings file to fill in the parameter values. For example:
- dotnet test --settings test.runsettings
- dotnet test --settings testrunsettings\test.runsettings --collect "Code coverage"
- dotnet test --settings test.runsettings --logger "console;verbosity=detailed"
- vstest.console.exe C:\Users\noell\source\repos\Test.Api\TestApiTests\bin\Debug\net5.0\TestApiTests.dll /Settings:.runsettings
- dotnet test -- NUnit.NumberOfTestWorkers=5

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)