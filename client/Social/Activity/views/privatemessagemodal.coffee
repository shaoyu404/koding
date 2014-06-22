class PrivateMessageModal extends KDModalViewWithForms

  constructor: (options = {}, data) ->

    options.title    or= 'START A PRIVATE CONVERSATION BETWEEN YOU AND:'
    options.cssClass or= 'private-message activity-modal'
    options.content  or= ''
    options.overlay   ?= yes
    options.width     ?= 660
    options.height   or= 'auto'
    options.arrowTop or= no
    # options.draggable  = handle : '.kdmodal' # breaks autocomplete focus
    options.tabs     or=
      forms            :
        Message        :
          callback     : @bound 'submitMessage'
          buttons      :
            send       :
              style    : 'message-send solid green'
              type     : 'submit'
              iconOnly : yes
            cancel     :
              title    : 'Nevermind'
              style    : 'transparent'
              callback : (event) =>
                @getDelegate()._lastMessage = null
                @destroy()
          fields           :
            recipient      :
              itemClass    : KDView
            body           :
              label        : ''
              name         : 'body'
              type         : 'textarea'
              defaultValue : options._lastMessage
              placeholder  : 'What\'s on your mind?'
              keyup        : @bound 'handleBodyKeyup'
              validate     :
                rules      : required : yes
                messages   : required : 'You forgot to put some message in.'

    super options, data

    {appManager, router} = KD.singletons
    appManager.tell 'Activity', 'bindModalDestroy', this, router.visitedRoutes.last

    @chatHeads?.destroy()
    @chatHeads = new KDView cssClass : 'chat-heads'

    @modalTabs.forms.Message.inputs.recipient.addSubView @chatHeads

    @createUserAutoComplete()
    @setFocus()

    if @getOption 'arrowTop'
      @addSubView (new KDCustomHTMLView
        cssClass : 'modal-arrow'
        position :
          top    : @getOption 'arrowTop'
      ), 'kdmodal-inner'

  setFocus : -> @autoComplete.getView().setFocus()

  submitMessage : ->

    {body} = @modalTabs.forms.Message.inputs
    {send} = @modalTabs.forms.Message.buttons
    val    = body.getValue()

    recipients = (nickname for {profile:{nickname}} in @autoComplete.getSelectedItemData())
    recipients = recipients.map (recipient)-> "@#{recipient}"
    recipients = recipients.join ' '

    val = "#{val} // #{recipients}"

    {router, socialapi, notificationController} = KD.singletons

    socialapi.message.sendPrivateMessage body : val, (err, channels) =>

      send.hideLoader()

      return KD.showError err  if err

      [channel]            = channels
      appView              = @getDelegate()
      appView._lastMessage = null

      router.handleRoute "/Activity/Message/#{channel.id}"

      @destroy()


  createUserAutoComplete: ->

    form                      = @modalTabs.forms.Message
    {fields, inputs, buttons} = form

    @autoComplete = new KDAutoCompleteController
      form                : form
      name                : 'userController'
      placeholder         : 'Type a username to start your conversation...'
      itemClass           : ActivityAutoCompleteUserItemView
      itemDataPath        : 'profile.nickname'
      outputWrapper       : @chatHeads
      selectedItemClass   : ChatHead
      listWrapperCssClass : 'private-message'
      submitValuesAsText  : yes
      dataSource          : @bound 'fetchAccounts'

    autoCompleteView = @autoComplete.getView()

    @autoComplete.on 'ItemListChanged', =>
      heads = @autoComplete.getSelectedItemData()
      autoCompleteView.setWidth inputs.recipient.getWidth() - heads.length * 35

    autoCompleteView.on 'keydown', @bound 'handleRecipientKeydown'

    inputs.recipient.addSubView autoCompleteView


  fetchAccounts: (args, callback) ->

    {JAccount}   = KD.remote.api
    {inputValue} = args

    val = inputValue.replace /^@/, ''

    return  if inputValue.length < 4

    query = 'profile.nickname': val

    JAccount.one query, (err, account) =>
      if not account or KD.isMine account
      then @autoComplete.showNoDataFound()
      else callback [account]

    #   byEmail = /[^\s@]+@[^\s@]+\.[^\s@]+/.test inputValue
    #   JAccount.byRelevance inputValue, {byEmail}, (err, accounts)->
    #     callback accounts


  handleBodyKeyup: (event) ->

    {body} = @modalTabs.forms.Message.inputs

    @getDelegate()._lastMessage = body.getValue()


  placeholderIsChanged_ = no

  handleRecipientKeydown: (event) ->

    return  unless lastItemData = @autoComplete.getSelectedItemData().last

    val    = @autoComplete.getView().getValue()
    input  = @autoComplete.getView()
    [item] = (item for item in @autoComplete.itemWrapper.getSubViews() when item.getData() is lastItemData)

    reset = ->
      input.setPlaceHolder 'Type a username to start your conversation...'
      item.unsetClass 'selected'
      placeholderIsChanged_ = no

    if event.which is 8 and val is ''

      if item.hasClass 'selected'
        @autoComplete.removeFromSubmitQueue item, lastItemData
        reset()
      else
        fullname = KD.utils.getFullnameFromAccount lastItemData
        input.setPlaceHolder "Hit backspace again to remove #{Encoder.htmlDecode fullname}"
        placeholderIsChanged_ = yes
        item.setClass 'selected'

    else

      reset()

