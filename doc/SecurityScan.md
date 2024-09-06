# MobSF Security scan integration

This project includes automated static application security testing (SAST) for the generated binaries for both iOS and Android. 
This is helpful to identify opportunities to reduce your app's susceptibility to attacks from malicious third parties. 
We use [MobSF](https://github.com/MobSF/Mobile-Security-Framework-MobSF) to scan the produced artifacts and generate a report with the analysis results.

## stage-security-scan.yml

This YAML configuration snippet outlines the setup for conditional security scanning within a CI/CD pipeline, specifically targeting iOS and Android platforms. The security scans are facilitated through the Mobile Security Framework (MobSF), a comprehensive tool designed for mobile security testing.

## Configuration Parameters
- **applicationEnvironment:** Specifies the deployment environment of the application. This string parameter helps in distinguishing artifacts by appending the environment name to the artifact's name.

- **enableIosSecurityScan:** A boolean parameter that, when set to true, enables security scanning for iOS applications.

- **enableAndroidSecurityScan:** Similar to enableIosSecurityScan, this boolean parameter enables security scanning for Android applications when set to true.

## Jobs Description
### iOS Security Scan Job (*OnLinux_iOS_SecurityScan*)
This job is designed to perform security scans on iOS applications. It is conditionally executed based on the `enableIosSecurityScan`  parameter.

- **Condition for Execution:** The job runs if `enableIosSecurityScan` is set to true.
- **Execution Environment:** The job is executed on a Linux-based virtual machine, specified by the ubuntuHostedAgentImage variable.
- **Key Steps:**
  - **Security Scan:** Utilizes a predefined template (`mobsf-scan.yml`) for conducting the security scan.
  - **Parameters Passed:**
    - `platform`: Specify the platform you'll be scanning.
    - `fileExtension`: Required to specify the file extension MobSF will scan.
    - `mobSfApiKey`: A key required for accessing MobSF services.
    - `artifactName`: The name of the iOS artifact, appended with the specified applicationEnvironment.

### Android Security Scan Job (*OnLinux_Android_SecurityScan*)
This job mirrors the iOS security scan job but targets Android applications. It is also conditionally executed based on a specific parameter.

 - **Condition for Execution:** The job runs if `enableAndroidSecurityScan` is set to true.
 - **Execution Environment:** Similar to the iOS job, it runs on a Linux-based virtual machine specified by the ubuntuHostedAgentImage variable.
 - **Key Steps:**
   - **Security Scan:** Executes a predefined template (`mobsf-scan.yml`) for the Android security scan.
   - **Parameters Passed:**
     - `platform`: Specify the platform you'll be scanning.
     - `fileExtension`: Specify the file extension MobSF will scan.
     - `mobSfApiKey`: Required key for MobSF services.
     - `artifactName`: The name of the Android artifact, appended with the specified applicationEnvironment.

## Usage
### How to Add the the new Stage for Security Scan

> 1. Create a new `stage`. (*stage: Security_Scan_Build_[Environment]*)
> 2. Configure the `dependsOn` property to the stage is creating the build, like `Build_Staging` and `Build_Production`.
> 3. Add the job we want to run using the new security template
> 4. Set the parameters `applicationEnvironment`, `enableIosSecurityScan`, `enableAndroidSecurityScan`

Integrating the security scanning configuration into your `azure-pipelines.yml` pipeline requires activating specific parameters to enable the process. Set `enableIosSecurityScan` and `enableAndroidSecurityScan` to **true** as per your project's requirements. This approach ensures a tailored security assessment for mobile applications across different environments, in this case Staging and Production, utilizing **MobSF** for comprehensive vulnerability detection prior to deployment.

## Output
After a successful build, the results of the security analysis are added as Artifacts for your CI pipelines. 
Two files are included: A PDF file (with a human-readable version of the scan results) and a JSON file which can be further analyzed, or even used as part of an automated process to identify specific portions of the report that can be of interest.

## References
- [MobSF Documentation](https://mobsf.github.io/docs/#/)
- [MobSF API Docs](https://mobsf.live/api_docs)