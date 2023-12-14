const core = require('@actions/core')
const uuid = require('crypto')
const fs = require('fs')

const filename = core.getInput('filename')
const autogeneratefilename = core.getInput('autogeneratefile')

try {
    const filenameToUse = !filename && autogeneratefilename ?  `${uuid.randomUUID()}.log` : `${filename}.log` 
    const input = 'just testing out  custom actions'
    
    fs.writeFileSync(filenameToUse, input)
}
catch(err) {
    core.setFailed(err)
}