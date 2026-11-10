package mods.gift_select_all_pages;

import mods.api.Context;
import mods.api.Mod;
import facade.DBFacade;
import collections.Map as GameMap;
import account.FriendInfo;
import brain.uI.UIButton;
import brain.uI.UIToggleButton;
import openfl.events.Event;

class Main extends Mod {
    var context:Context;
    var facade:DBFacade;
    var social:Dynamic;
    var list:Dynamic;
    var allButton:UIButton;
    var noneButton:UIButton;
    var originalAll:Dynamic;
    var originalNone:Dynamic;
    var failed:Bool = false;

    override public function init(context:Context):Void {
        this.context = context;
        context.core.onStateEnter(function(machine, state) {
            if (Type.getClassName(Type.getClass(state)) == "town.SocialSubState") {
                social = state;
                failed = false;
            }
        });
        context.core.onStateExit(function(machine, state) {
            if (state == social) {
                detach();
                social = null;
            }
        });
        context.overlay.addEventListener(Event.ENTER_FRAME, update);
    }

    override public function ready(context:Context):Void {
        facade = context.core.facade;
        context.log("loaded; waiting for the Friends tab");
    }

    override public function dispose():Void {
        context.overlay.removeEventListener(Event.ENTER_FRAME, update);
        detach();
        social = null;
        facade = null;
    }

    function update(event:Event):Void {
        if (social == null || facade == null || failed || !context.core.alive) return;
        try {
            var manager:Dynamic = Reflect.field(social, "mUIFriendManager");
            var next:Dynamic = null;
            if (manager != null && manager.currentState == 1) {
                var states:GameMap = cast Reflect.field(manager, "states");
                var friends:Dynamic = states == null ? null : states.itemFor(1);
                if (friends != null) next = Reflect.field(friends, "mFriendPopulater");
            }
            if (next == list) return;
            detach();
            if (next == null) return;
            var all:UIButton = cast Reflect.field(next, "mSelectAllButton");
            var none:UIButton = cast Reflect.field(next, "mSelectNoneButton");
            if (all == null || none == null) return;
            list = next;
            allButton = all;
            noneButton = none;
            originalAll = all.releaseCallback;
            originalNone = none.releaseCallback;
            all.releaseCallback = selectAll;
            none.releaseCallback = selectNone;
            context.log("attached Select All / None across all friend pages");
        } catch (error:Dynamic) {
            failed = true;
            detach();
            context.log("could not attach selection controls: " + Std.string(error));
        }
    }

    function selectAll():Void {
        if (list == null) return;
        var friends:Dynamic = Reflect.field(list, "mListOfFriends");
        var selected:GameMap = cast Reflect.field(list, "mFriendsSelectedAcrossPages");
        if (friends == null || selected == null) return;
        var excluded = facade.dbAccountInfo.giftExcludeIds;
        selected.clear();
        for (index in 0...friends.length) {
            var friend:FriendInfo = cast friends[index];
            if (friend != null && excluded.indexOf(friend.excludeId) < 0) {
                selected.add(index, true);
            }
        }
        Reflect.setField(list, "SelectAllButtonSelected", true);
        Reflect.setField(list, "NoneButtonSelected", false);
        refreshVisible(selected);
        context.log("selected " + selected.size + " eligible friends across all pages");
    }

    function selectNone():Void {
        if (list == null) return;
        var selected:GameMap = cast Reflect.field(list, "mFriendsSelectedAcrossPages");
        if (selected == null) return;
        selected.clear();
        Reflect.setField(list, "SelectAllButtonSelected", false);
        Reflect.setField(list, "NoneButtonSelected", true);
        refreshVisible(selected);
        context.log("cleared selection across all pages");
    }

    function refreshVisible(selected:GameMap):Void {
        var toggles:GameMap = cast Reflect.field(list, "mFriendSelectedToggles");
        var slots:Dynamic = Reflect.field(list, "mListOfFriendSlots");
        var page:Int = Reflect.field(list, "mCurrentPage");
        if (toggles == null || slots == null) return;
        // V17 has five columns and three rows. The master map uses absolute indices.
        for (index in 0...slots.length) {
            var toggle:UIToggleButton = cast toggles.itemFor(index);
            if (toggle != null) toggle.selected = selected.hasKey(page * 15 + index);
        }
    }

    function detach():Void {
        if (allButton != null && Reflect.compareMethods(allButton.releaseCallback, selectAll)) {
            allButton.releaseCallback = originalAll;
        }
        if (noneButton != null && Reflect.compareMethods(noneButton.releaseCallback, selectNone)) {
            noneButton.releaseCallback = originalNone;
        }
        list = null;
        allButton = null;
        noneButton = null;
        originalAll = null;
        originalNone = null;
    }
}
