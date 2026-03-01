require("Archipelago.Utils")

CoD.ArchipelagoMessageContainer = InheritFrom( LUI.UIElement )
CoD.ArchipelagoMessageContainer.MessagesQueue = List.new()
CoD.ArchipelagoMessageContainer.new = function (menu, controller)
    local self = LUI.UIElement.new()

    self:setClass(CoD.ArchipelagoMessageContainer)
    self.id = "ArchipelagoMessageContainer"
    self.soundSet = "default"
    self:setLeftRight(true, true, 0, 0)
    self:setTopBottom(true, true, 0, 0)

    --AP Get Image
    
    local ApGetImage = LUI.UIImage.new()
    ApGetImage:setLeftRight(true, false, 30, 70)
    ApGetImage:setTopBottom(true, false, 30, 78)
    ApGetImage:setImage(RegisterImage("archipelago_logo_down"))
    ApGetImage:setAlpha(0)
    self:addElement(ApGetImage)
    self.ApGetImage = ApGetImage

    local ApGetTextSender = LUI.UIText.new()
    ApGetTextSender:setLeftRight(true, true, 95, 85)
    ApGetTextSender:setTopBottom(true, false, 30, 46)
    ApGetTextSender:setAlpha(0)
    ApGetTextSender:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    ApGetTextSender:setText("TEST VALUE LONG STRING YUPPERS")
    self:addElement(ApGetTextSender)
    self.ApGetTextSender = ApGetTextSender

    local ApGetText = LUI.UIText.new()
    ApGetText:setLeftRight(true, true, 85, 85)
    ApGetText:setTopBottom(true, false, 48, 78)
    ApGetText:setAlpha(0)
    ApGetText:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    ApGetText:setText("TEST VALUE LONG STRING YUPPERS")
    self:addElement(ApGetText)
    self.ApGetText = ApGetText

    --AP Send Image
    
    local ApSendImage = LUI.UIImage.new()
    ApSendImage:setLeftRight(true, false, 30, 70)
    ApSendImage:setTopBottom(true, false, 93, 141)
    ApSendImage:setImage(RegisterImage("archipelago_logo_up"))
    ApSendImage:setAlpha(0)
    self:addElement(ApSendImage)
    self.ApSendImage = ApSendImage

    local ApSendText = LUI.UIText.new()
    ApSendText:setLeftRight(true, true, 95, 85)
    ApSendText:setTopBottom(true, false, 93, 109)
    ApSendText:setAlpha(0)
    ApSendText:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    ApSendText:setText("TEST VALUE LONG STRING YUPPERS")
    self:addElement(ApSendText)
    self.ApSendText = ApSendText

    local ApSendTextSender = LUI.UIText.new()
    ApSendTextSender:setLeftRight(true, true, 85, 85)
    ApSendTextSender:setTopBottom(true, false, 111, 141)
    ApSendTextSender:setAlpha(0)
    ApSendTextSender:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    ApSendTextSender:setText("TEST VALUE LONG STRING YUPPERS")
    self:addElement(ApSendTextSender)
    self.ApSendTextSender = ApSendTextSender

    local AnimationFrame4 = function( element, event )
      if not event.interrupted then
        element:beginAnimation( "keyframe", 1000, false, false, CoD.TweenType.Linear )
      end
      element:setAlpha( 0 )
      if not event.interrupted then
        element:registerEventHandler( "transition_complete_keyframe", nil )
      end
    end
    
    local AnimationFrame3 = function( element, event )
      if event.interrupted then
        AnimationFrame4( element, event )
        return
      else
        element:beginAnimation( "keyframe", 2900, false, false, CoD.TweenType.Linear )
        element:registerEventHandler( "transition_complete_keyframe", AnimationFrame4 )
      end
    end
    
    local AnimationFrame2 = function( element, event )
      if event.interrupted then
        AnimationFrame3( element, event )
        return
      else
        element:beginAnimation( "keyframe", 100, false, false, CoD.TweenType.Linear )
        element:setAlpha( 1 )
        element:registerEventHandler( "transition_complete_keyframe", AnimationFrame3 )
      end
    end

    local FlashNotifWrap = function(event, networkItem)
      if event == "GET" then
        self.ApGetText:setText( Engine.Localize(networkItem.name) )
        self.ApGetTextSender:setText( Engine.Localize(networkItem.location .. " in ^8" .. networkItem.sender .. "'s ^7world") )
        AnimationFrame2(self.ApGetImage,{})
        AnimationFrame2(self.ApGetText,{})
        AnimationFrame2(self.ApGetTextSender,{})
      else
        self.ApSendText:setText( Engine.Localize(networkItem.location) )
        self.ApSendTextSender:setText( Engine.Localize("^8" .. networkItem.sender .. "'s ^7" ..networkItem.name) )
        AnimationFrame2(self.ApSendImage,{})
        AnimationFrame2(self.ApSendText,{})
        AnimationFrame2(self.ApSendTextSender,{})
      end
    end

    if Archi then
      Archi.RegisterNotifyFunc(FlashNotifWrap)
    end
    
    --Close callback (Close all the children stuff)
    LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
        element.ApGetImage:close()
        element.ApGetText:close()
        element.ApGetTextSender:close()
        element.ApSendImage:close()
        element.ApSendText:close()
        element.ApSendTextSender:close()
        if Archi then
          Archi.UnregisterNotifyFunc()
        end
	  end )

    return self
end

