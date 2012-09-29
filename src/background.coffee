settings = new Store("settings", {
	"blacklist": "gmail.com,reader.google.com"
})

chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
	if (request.action == 'gpmeGetOptions')
		sendResponse(settings.toObject())
