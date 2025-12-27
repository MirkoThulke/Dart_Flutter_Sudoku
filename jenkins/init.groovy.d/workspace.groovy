import jenkins.model.Jenkins
import java.io.File

def workspaceDir = new File("/workspace")

if (!workspaceDir.exists()) {
    workspaceDir.mkdirs()
}

Jenkins.instance.setWorkspaceRoot(workspaceDir)
Jenkins.instance.save() 