import jenkins.model.Jenkins
import java.io.File

// Define the new workspace root
def workspaceDir = new File("/workspace")

// Ensure the directory exists
if (!workspaceDir.exists()) {
    workspaceDir.mkdirs()
}

// Set the Jenkins workspace root
Jenkins.instance.setWorkspaceDir(workspaceDir)
println "✅ Workspace root set to ${workspaceDir.absolutePath}"

// Persist configuration
Jenkins.instance.save()