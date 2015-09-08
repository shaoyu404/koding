ChatInputModule = require './chatinput'

module.exports =
  getters   : require './getters'

  actions   :
    message         : require './actions/message'
    thread          : require './actions/thread'
    channel         : require './actions/channel'
    suggestions     : require './actions/suggestions'

  stores    : [
    require './stores/messagesstore'
    require './stores/channelsstore'
    require './stores/channelthreadsstore'
    require './stores/messagethreadssstore'
    require './stores/selectedchannelthreadidstore'
    require './stores/selectedmessagethreadidstore'
    require './stores/followedpublicchannelidsstore'
    require './stores/followedprivatechannelidsstore'
    require './stores/popularchannelidsstore'
    require './stores/channelparticipantidsstore'
    require './stores/channelpopularmessageidsstore'
    require './stores/suggestions/suggestionsquerystore'
    require './stores/suggestions/suggestionsflagsstore'
    require './stores/suggestions/suggestionsstore'
    require './stores/suggestions/suggestionsselectedindexstore'
    require './stores/messagelikerssstore'
    require './stores/channelflagsstore'
    require './stores/messageflagsstore'
    require './stores/channelparticipants/channelparticipantssearchquerystore'
    require './stores/channelparticipants/channelparticipantsdropdownvisibilitystore'
    require './stores/channelparticipants/channelparticipantsselectedindexstore'

  ]
  # module stores
  .concat ChatInputModule.stores

