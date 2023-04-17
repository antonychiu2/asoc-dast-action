const core =require('@actions/core');

//console.log(process.env)
var PSFileToRun = "main.ps1";
process.env['GITHUB_ACTION_PATH'] = process.env.HOME+"/work/_actions/"+process.env.GITHUB_ACTION_REPOSITORY+"/"+process.env.GITHUB_ACTION_REF;

console.log('Constructed github action path: '+process.env.GITHUB_ACTION_PATH)
console.log('Starting URL in main.js: '+process.env.INPUT_STARTING_URL)

var spawn = require("child_process").spawn,child;
child = spawn("pwsh",[process.env.GITHUB_ACTION_PATH+"/"+PSFileToRun]);
child.stdout.on("data",function(data){
    process.stdout.write("" + data);

});
child.stderr.on("data",function(data){
    process.stdout.write("Errors: " + data);
    core.error("" + data);

    process.exit(1);
});
child.on("exit",function(){
    process.stdout.write("");
    //core.warning("Issue Count by Severity: " + process.env.ISSUE_COUNT_BY_SEV);

});
child.stdin.end(); //end input
