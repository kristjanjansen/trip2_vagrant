var http = require('http')
var exec = require('child_process').exec
var fs = require('fs')

var webhookHandler = require('github-webhook-handler')
var yaml = require('js-yaml');
var slackNotify = require('slack-notify');
var ip = require('ip');

var config = yaml.safeLoad(fs.readFileSync('./deploy.yaml', 'utf8'))
var slack = slackNotify(config.slack)
var handler = webhookHandler({ path: '/webhook', secret: 'secret' })

var port = 3333

console.log('Starting deploy server. Github webhook: http://' + ip.address() + ':' + port + '/webhook')

http.createServer(function (req, res) {
  handler(req, res, function (err) {
    res.statusCode = 404
    res.end('Nope')
  })
}).listen(port)

handler.on('error', function (err) {
    console.error(err.message)
})

handler.on('push', function (ev) {
  
    if (ev.payload.ref == 'refs/heads/' + config.branch) {
  
        console.log('Commit: ' + ev.payload.head_commit.url);
  
        exec('cd ../trip2 && sh ../scripts/deploy.sh', function (error, stdout, stderr) {
            
            if (stdout) console.log(stdout)
            if (stderr) console.log(stderr)
            
            slack.send({
                channel: '#servers',
                icon_emoji: config.emoji,
                username: config.environment,
                text: 'A new commit has been deployed',
                fields: {
                    'Message': ev.payload.head_commit.message,
                    'Committer': ev.payload.head_commit.committer.name,
                    'Link': ev.payload.head_commit.url,
                    'Output': stdout,
                    'Errors': stderr
                }
            })

        });
  
    }
})
