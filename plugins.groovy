// List of plugins to check and install
def plugins = [
    'workflow-aggregator',  // Pipeline plugin
    'git',                  // Git plugin
    'pipeline-utility-steps', // Pipeline utility steps plugin
    'maven-plugin',         // Maven plugin
    'sonar',                // SonarQube scanner plugin
    'quality-gates',        // Quality gates plugin (for SonarQube quality gate)
    'docker-workflow'       // Docker pipeline plugin
]

// Get Jenkins instance and plugin manager
def jenkinsInstance = Jenkins.getInstance()
def pluginManager = jenkinsInstance.getPluginManager()
def updateCenter = jenkinsInstance.getUpdateCenter()

// Function to check if a plugin is installed
def isPluginInstalled(pluginName) {
    return pluginManager.getPlugin(pluginName) != null
}

// Track if plugins were installed or updated
def pluginsInstalledOrUpdated = false

// Install missing plugins
plugins.each { plugin ->
    if (!isPluginInstalled(plugin)) {
        def pluginToInstall = updateCenter.getPlugin(plugin)
        if (pluginToInstall) {
            println "Installing plugin: ${plugin}"
            pluginToInstall.deploy()
            pluginsInstalledOrUpdated = true
        } else {
            println "Plugin ${plugin} not found."
        }
    } else {
        println "Plugin ${plugin} is already installed."
    }
}

// Save the Jenkins instance
jenkinsInstance.save()

// Check if the plugins were installed successfully
plugins.each { plugin ->
    if (isPluginInstalled(plugin)) {
        println "✅ Plugin ${plugin} is installed."
    } else {
        println "❌ Plugin ${plugin} is NOT installed."
    }
}

// Restart Jenkins only if plugins were installed or updated
if (pluginsInstalledOrUpdated) {
    println "Plugins installation or update detected. Restarting Jenkins..."
    jenkinsInstance.restart()
} else {
    println "No changes detected. Jenkins will not be restarted."
}

