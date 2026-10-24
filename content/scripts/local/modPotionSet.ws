// Mod: Potion Set (Zestaw Eliksirow) for The Witcher 3

function ModPotionSet_IsPolish() : bool
{
	var audioLang, textLang : string;
	theGame.GetGameLanguageName( audioLang, textLang );
	return textLang == "PL";
}

function ModPotionSet_IsRegularPotion( inv : CInventoryComponent, itemId : SItemUniqueId ) : bool
{
	if ( !inv || !inv.IsIdValid( itemId ) )
	{
		return false;
	}
	if ( !inv.ItemHasTag( itemId, 'Potion' ) )
	{
		return false;
	}
	if ( inv.ItemHasTag( itemId, 'Mutagen' ) || inv.ItemHasTag( itemId, 'Edibles' ) || inv.ItemHasTag( itemId, 'NoEquip' ) )
	{
		return false;
	}
	return true;
}

function ModPotionSet_GetBaseKey( itemName : name ) : string
{
	var str : string;
	str = NameToString( itemName );
	if ( StrEndsWith( str, " 1" ) || StrEndsWith( str, " 2" ) || StrEndsWith( str, " 3" ) )
	{
		str = StrLeft( str, StrLen( str ) - 2 );
	}
	str = StrReplaceAll( StrLower( str ), " ", "_" );
	return str;
}

function ModPotionSet_GetFactName( itemName : name, optional setIdx : int ) : string
{
	if ( setIdx <= 1 )
	{
		return "mod_potion_set_1_slot_" + ModPotionSet_GetBaseKey( itemName );
	}
	return "mod_potion_set_2_slot_" + ModPotionSet_GetBaseKey( itemName );
}

function ModPotionSet_SetFact( factName : string, val : int )
{
	theGame.GameplayFactsSet( factName, val );
	FactsSet( factName, val, -1 );
}

function ModPotionSet_GetFact( factName : string, optional legacyFactName : string ) : int
{
	var val : int;
	val = theGame.GameplayFactsQuerySum( factName );
	if ( val <= 0 )
	{
		val = FactsQuerySum( factName );
		if ( val > 0 )
		{
			theGame.GameplayFactsSet( factName, val );
		}
	}
	if ( val <= 0 && StrLen( legacyFactName ) > 0 )
	{
		val = theGame.GameplayFactsQuerySum( legacyFactName );
		if ( val <= 0 )
		{
			val = FactsQuerySum( legacyFactName );
		}
		if ( val > 0 )
		{
			theGame.GameplayFactsSet( factName, val );
			FactsSet( factName, val, -1 );
			theGame.GameplayFactsRemove( legacyFactName );
			FactsRemove( legacyFactName );
		}
	}
	return val;
}

function ModPotionSet_RemoveFact( factName : string )
{
	theGame.GameplayFactsRemove( factName );
	if ( FactsDoesExist( factName ) )
	{
		FactsRemove( factName );
	}
}

function ModPotionSet_GetOrderedItems( out orderedItems : array<SItemUniqueId>, optional setIdx : int )
{
	var inv : CInventoryComponent;
	var allPotions : array<SItemUniqueId>;
	var slotItems : array<SItemUniqueId>;
	var i, slotIdx, newSlot : int;
	var curItem : SItemUniqueId;
	var factName, legacyFact : string;

	if ( setIdx <= 0 )
	{
		setIdx = 1;
	}

	orderedItems.Clear();

	if ( !thePlayer )
	{
		return;
	}

	inv = thePlayer.GetInventory();
	if ( !inv )
	{
		return;
	}

	slotItems.Resize( 5 );
	for ( i = 0; i < 5; i += 1 )
	{
		slotItems[i] = GetInvalidUniqueId();
	}

	allPotions = inv.GetItemsByTag( 'Potion' );
	for ( i = 0; i < allPotions.Size(); i += 1 )
	{
		curItem = allPotions[i];
		if ( !ModPotionSet_IsRegularPotion( inv, curItem ) )
		{
			continue;
		}

		factName = ModPotionSet_GetFactName( inv.GetItemName( curItem ), setIdx );
		if ( setIdx == 1 )
		{
			legacyFact = "mod_potion_set_slot_" + ModPotionSet_GetBaseKey( inv.GetItemName( curItem ) );
		}
		else
		{
			legacyFact = "";
		}
		slotIdx = ModPotionSet_GetFact( factName, legacyFact );
		if ( slotIdx >= 1 && slotIdx <= 4 )
		{
			if ( !inv.IsIdValid( slotItems[slotIdx] ) )
			{
				slotItems[slotIdx] = curItem;
			}
		}
	}

	newSlot = 1;
	for ( slotIdx = 1; slotIdx <= 4; slotIdx += 1 )
	{
		if ( inv.IsIdValid( slotItems[slotIdx] ) )
		{
			orderedItems.PushBack( slotItems[slotIdx] );
			if ( slotIdx != newSlot )
			{
				ModPotionSet_SetFact( ModPotionSet_GetFactName( inv.GetItemName( slotItems[slotIdx] ), setIdx ), newSlot );
			}
			newSlot += 1;
		}
	}
}

function ModPotionSet_GetCount( optional setIdx : int ) : int
{
	var orderedItems : array<SItemUniqueId>;
	if ( setIdx <= 0 )
	{
		setIdx = 1;
	}
	ModPotionSet_GetOrderedItems( orderedItems, setIdx );
	return orderedItems.Size();
}

function ModPotionSet_GetPotionSlotIndex( itemId : SItemUniqueId, optional setIdx : int ) : int
{
	var orderedItems : array<SItemUniqueId>;
	var i : int;

	if ( setIdx <= 0 )
	{
		setIdx = 1;
	}
	ModPotionSet_GetOrderedItems( orderedItems, setIdx );
	for ( i = 0; i < orderedItems.Size(); i += 1 )
	{
		if ( orderedItems[i] == itemId )
		{
			return i + 1;
		}
	}
	return 0;
}

function ModPotionSet_TogglePotion( itemId : SItemUniqueId, optional setIdx : int ) : int
{
	var inv : CInventoryComponent;
	var orderedItems : array<SItemUniqueId>;
	var existingIdx, i, newSlot : int;

	if ( setIdx <= 0 )
	{
		setIdx = 1;
	}

	if ( !thePlayer )
	{
		return -1;
	}

	inv = thePlayer.GetInventory();
	if ( !ModPotionSet_IsRegularPotion( inv, itemId ) )
	{
		return -1;
	}

	ModPotionSet_GetOrderedItems( orderedItems, setIdx );

	existingIdx = -1;
	for ( i = 0; i < orderedItems.Size(); i += 1 )
	{
		if ( orderedItems[i] == itemId )
		{
			existingIdx = i;
			break;
		}
	}

	if ( existingIdx != -1 )
	{
		ModPotionSet_RemoveFact( ModPotionSet_GetFactName( inv.GetItemName( itemId ), setIdx ) );
		if ( setIdx == 1 )
		{
			ModPotionSet_RemoveFact( "mod_potion_set_slot_" + ModPotionSet_GetBaseKey( inv.GetItemName( itemId ) ) );
		}
		orderedItems.Erase( existingIdx );

		for ( i = 0; i < orderedItems.Size(); i += 1 )
		{
			ModPotionSet_SetFact( ModPotionSet_GetFactName( inv.GetItemName( orderedItems[i] ), setIdx ), i + 1 );
		}
		return 0;
	}

	if ( orderedItems.Size() >= 4 )
	{
		return -1;
	}

	newSlot = orderedItems.Size() + 1;
	ModPotionSet_SetFact( ModPotionSet_GetFactName( inv.GetItemName( itemId ), setIdx ), newSlot );
	return newSlot;
}

function ModPotionSet_ClearSet( optional setIdx : int )
{
	var inv : CInventoryComponent;
	var allPotions : array<SItemUniqueId>;
	var i : int;

	if ( !thePlayer )
	{
		return;
	}

	inv = thePlayer.GetInventory();
	if ( !inv )
	{
		return;
	}

	allPotions = inv.GetItemsByTag( 'Potion' );
	for ( i = 0; i < allPotions.Size(); i += 1 )
	{
		if ( setIdx == 1 || setIdx <= 0 )
		{
			ModPotionSet_RemoveFact( ModPotionSet_GetFactName( inv.GetItemName( allPotions[i] ), 1 ) );
			ModPotionSet_RemoveFact( "mod_potion_set_slot_" + ModPotionSet_GetBaseKey( inv.GetItemName( allPotions[i] ) ) );
		}
		if ( setIdx == 2 || setIdx <= 0 )
		{
			ModPotionSet_RemoveFact( ModPotionSet_GetFactName( inv.GetItemName( allPotions[i] ), 2 ) );
		}
	}
}

function ModPotionSet_GetInventoryButtonLabel() : string
{
	var count1, count2 : int;
	count1 = ModPotionSet_GetCount( 1 );
	count2 = ModPotionSet_GetCount( 2 );
	return "Zestawy eliksirow (Z1: " + count1 + "/4 | Z2: " + count2 + "/4)";
}

function ModPotionSet_GetHeaderText( optional setIdx : int ) : string
{
	var count : int;
	if ( setIdx <= 0 )
	{
		setIdx = 1;
	}
	count = ModPotionSet_GetCount( setIdx );
	return "ZESTAW " + setIdx + " (" + count + "/4)";
}

function ModPotionSet_StripHtml( text : string ) : string
{
	var startIdx, endIdx : int;
	var tag : string;

	while ( true )
	{
		startIdx = StrFindFirst( text, "<" );
		if ( startIdx < 0 )
		{
			break;
		}
		endIdx = StrFindFirst( text, ">" );
		if ( endIdx < startIdx )
		{
			text = StrLeft( text, startIdx );
			break;
		}
		tag = StrMid( text, startIdx, (endIdx - startIdx) + 1 );
		if ( tag == "<br>" || tag == "<br/>" || tag == "<br />" )
		{
			text = StrReplace( text, tag, " " );
		}
		else
		{
			text = StrReplace( text, tag, "" );
		}
	}

	return text;
}

function ModPotionSet_GetPopupDescriptionText( selectedItemId : SItemUniqueId, optional activeSetIdx : int ) : string
{
	var inv : CInventoryComponent;
	var currentItems : array<SItemUniqueId>;
	var i, slotIdx, ammo, nextSlot : int;
	var potName, lineItem, lineNav, resultText, nl : string;

	if ( activeSetIdx <= 0 )
	{
		activeSetIdx = 1;
	}

	nl = StrChar( 10 );

	if ( !thePlayer )
	{
		return "";
	}

	inv = thePlayer.GetInventory();
	if ( !inv )
	{
		return "";
	}

	ModPotionSet_GetOrderedItems( currentItems, activeSetIdx );

	if ( currentItems.Size() == 0 )
	{
		resultText = "ZESTAW " + activeSetIdx + " (0/4): Pusty";
	}
	else
	{
		resultText = "ZESTAW " + activeSetIdx + " (" + currentItems.Size() + "/4):";
		for ( i = 0; i < currentItems.Size(); i += 1 )
		{
			potName = GetLocStringByKeyExt( inv.GetItemLocalizedNameByUniqueID( currentItems[i] ) );
			if ( StrLen( potName ) == 0 )
			{
				potName = NameToString( inv.GetItemName( currentItems[i] ) );
			}
			ammo = inv.SingletonItemGetAmmo( currentItems[i] );
			resultText += nl + "[#" + (i + 1) + "] " + potName + " (" + ammo + ")";
		}
	}

	if ( inv.IsIdValid( selectedItemId ) )
	{
		slotIdx = ModPotionSet_GetPotionSlotIndex( selectedItemId, activeSetIdx );
		if ( slotIdx > 0 )
		{
			lineItem = "[W ZESTAWIE " + activeSetIdx + ": #" + slotIdx + "]  2x LPM / E: Usun z Zestawu " + activeSetIdx;
		}
		else
		{
			if ( currentItems.Size() >= 4 )
			{
				lineItem = "[ZESTAW " + activeSetIdx + " PELNY (4/4)]  Wybierz eliksir z zestawu, aby zwolnic miejsce";
			}
			else
			{
				nextSlot = currentItems.Size() + 1;
				lineItem = "[POZYCJA: #" + nextSlot + " w Zestawie " + activeSetIdx + "]  2x LPM / E: Dodaj do Zestawu " + activeSetIdx;
			}
		}
	}

	lineNav = "Nawigacja: 1 / 3 (LB / RB) - zmien zestaw  •  2x LPM / E - dodaj/usun  •  R - wyczysc  •  Esc - wyjdz";

	if ( StrLen( lineItem ) > 0 )
	{
		resultText += nl + nl + lineItem;
	}
	resultText += nl + lineNav;

	return resultText;
}

/* old implementation
{
	var inv : CInventoryComponent;
	var set1Items, set2Items : array<SItemUniqueId>;
	var i, slotIdx, ammo, nextSlot : int;
	var potName, lineSet1, lineSet2, lineItem, lineNav, resultText, nl : string;

	if ( activeSetIdx <= 0 )
	{
		activeSetIdx = 1;
	}

	nl = StrChar( 10 );

	if ( !thePlayer )
	{
		return "";
	}

	inv = thePlayer.GetInventory();
	if ( !inv )
	{
		return "";
	}

	ModPotionSet_GetOrderedItems( set1Items, 1 );
	ModPotionSet_GetOrderedItems( set2Items, 2 );

	if ( set1Items.Size() == 0 )
	{
		lineSet1 = "ZESTAW 1 (0/4): Pusty";
	}
	else
	{
		lineSet1 = "ZESTAW 1 (" + set1Items.Size() + "/4): ";
		for ( i = 0; i < set1Items.Size(); i += 1 )
		{
			if ( i > 0 )
			{
				lineSet1 += " | ";
			}
			potName = GetLocStringByKeyExt( inv.GetItemLocalizedNameByUniqueID( set1Items[i] ) );
			ammo = inv.SingletonItemGetAmmo( set1Items[i] );
			lineSet1 += "[#" + (i + 1) + "] " + potName + " (" + ammo + ")";
		}
	}
	if ( activeSetIdx == 1 )
	{
		lineSet1 = "-> " + lineSet1;
	}

	if ( set2Items.Size() == 0 )
	{
		lineSet2 = "ZESTAW 2 (0/4): Pusty";
	}
	else
	{
		lineSet2 = "ZESTAW 2 (" + set2Items.Size() + "/4): ";
		for ( i = 0; i < set2Items.Size(); i += 1 )
		{
			if ( i > 0 )
			{
				lineSet2 += " | ";
			}
			potName = GetLocStringByKeyExt( inv.GetItemLocalizedNameByUniqueID( set2Items[i] ) );
			ammo = inv.SingletonItemGetAmmo( set2Items[i] );
			lineSet2 += "[#" + (i + 1) + "] " + potName + " (" + ammo + ")";
		}
	}
	if ( activeSetIdx == 2 )
	{
		lineSet2 = "-> " + lineSet2;
	}

	if ( inv.IsIdValid( selectedItemId ) )
	{
		slotIdx = ModPotionSet_GetPotionSlotIndex( selectedItemId, activeSetIdx );
		if ( slotIdx > 0 )
		{
			lineItem = "[W ZESTAWIE " + activeSetIdx + ": #" + slotIdx + "]  2x LPM / E: Usun z Zestawu " + activeSetIdx;
		}
		else
		{
			if ( ( activeSetIdx == 1 && set1Items.Size() >= 4 ) || ( activeSetIdx == 2 && set2Items.Size() >= 4 ) )
			{
				lineItem = "[ZESTAW " + activeSetIdx + " PELNY (4/4)]  Wybierz eliksir z zestawu, aby zwolnic miejsce";
			}
			else
			{
				nextSlot = ( activeSetIdx == 1 ) ? ( set1Items.Size() + 1 ) : ( set2Items.Size() + 1 );
				lineItem = "[POZYCJA: #" + nextSlot + " w Zestawie " + activeSetIdx + "]  2x LPM / E: Dodaj do Zestawu " + activeSetIdx;
			}
		}
	}

	lineNav = "Nawigacja: 1 / 3 (LB / RB) - zmien zestaw  •  2x LPM / E - dodaj/usun  •  R - wyczysc  •  Esc - wyjdz";

	resultText = lineSet1 + nl + lineSet2;
	if ( StrLen( lineItem ) > 0 )
	{
		resultText += nl + lineItem;
	}
	resultText += nl + lineNav;

	return resultText;
}

*/

function ModPotionSet_DrinkSet( optional setIdx : int ) : bool
{
	var witcher : W3PlayerWitcher;
	var inv : CInventoryComponent;
	var orderedItems : array<SItemUniqueId>;
	var i, usedCount, toxBlockedCount, emptyCount : int;
	var curItem : SItemUniqueId;
	var effectType : EEffectType;
	var customAbilityName : name;
	var finalPotionToxicity, toxicityOffset, adrenaline : float;
	var usedNames : string;
	var potName, messageText, language, audioLanguage : string;
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleItemInfo;

	if ( setIdx <= 0 )
	{
		setIdx = 1;
	}

	if ( !thePlayer || thePlayer.IsCiri() )
	{
		return false;
	}

	witcher = GetWitcherPlayer();
	if ( !witcher )
	{
		return false;
	}

	if ( !thePlayer.IsActionAllowed( EIAB_QuickSlots ) )
	{
		thePlayer.DisplayActionDisallowedHudMessage( EIAB_QuickSlots );
		return false;
	}

	inv = thePlayer.GetInventory();
	ModPotionSet_GetOrderedItems( orderedItems, setIdx );

	if ( orderedItems.Size() == 0 )
	{
		thePlayer.DisplayHudMessage( "Zestaw " + setIdx + " jest pusty - ustaw go w ekwipunku" );
		theSound.SoundEvent( "gui_global_denied" );
		return false;
	}

	usedCount = 0;
	toxBlockedCount = 0;
	emptyCount = 0;
	usedNames = "";

	for ( i = 0; i < orderedItems.Size(); i += 1 )
	{
		curItem = orderedItems[i];
		if ( !inv.IsIdValid( curItem ) )
		{
			continue;
		}

		if ( inv.IsItemSingletonItem( curItem ) && inv.SingletonItemGetAmmo( curItem ) <= 0 )
		{
			emptyCount += 1;
			continue;
		}

		inv.GetPotionItemBuffData( curItem, effectType, customAbilityName );

		if ( witcher.HasFreeToxicityToDrinkPotion( curItem, effectType, finalPotionToxicity, toxicityOffset, adrenaline ) && witcher.ToxicityLowEnoughToDrinkPotion( EES_Potion1, curItem ) )
		{
			witcher.DrinkPreparedPotion( EES_Potion1, curItem );
			potName = GetLocStringByKeyExt( inv.GetItemLocalizedNameByUniqueID( curItem ) );
			if ( usedCount > 0 )
			{
				usedNames += ", ";
			}
			usedNames += potName;
			usedCount += 1;
		}
		else
		{
			toxBlockedCount += 1;
		}
	}

	if ( usedCount > 0 )
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			module = (CR4HudModuleItemInfo)hud.GetHudModule( "ItemInfoModule" );
			if ( module )
			{
				module.ForceShowElement();
			}
		}

		messageText = "Uzyto Zestawu " + setIdx + ": " + usedNames;
		if ( toxBlockedCount > 0 )
		{
			messageText += " (toksycznosc: " + (int)(witcher.abilityManager.GetStat( BCS_Toxicity, false )) + "/" + (int)(witcher.abilityManager.GetStatMax( BCS_Toxicity )) + ")";
		}
		thePlayer.DisplayHudMessage( messageText );
		return true;
	}
	else if ( toxBlockedCount > 0 )
	{
		messageText = GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) + " " + GetLocStringByKeyExt( "panel_common_statistics_tooltip_current_toxicity" );
		theGame.GetGameLanguageName( audioLanguage, language );
		if ( language == "AR" )
		{
			messageText += (int)(witcher.abilityManager.GetStat( BCS_Toxicity, false )) + " / " + (int)(witcher.abilityManager.GetStatMax( BCS_Toxicity )) + " :";
		}
		else
		{
			messageText += ": " + (int)(witcher.abilityManager.GetStat( BCS_Toxicity, false )) + " / " + (int)(witcher.abilityManager.GetStatMax( BCS_Toxicity ));
		}
		thePlayer.DisplayHudMessage( messageText );
		theSound.SoundEvent( "gui_global_denied" );
		return false;
	}
	else if ( emptyCount > 0 )
	{
		thePlayer.DisplayHudMessage( "Brak ladunkow eliksirow w Zestawie " + setIdx );
		theSound.SoundEvent( "gui_global_denied" );
		return false;
	}

	return false;
}

class W3GuiPotionSetSelectComponent extends W3GuiSelectItemComponent
{
	public var displayedItems : array<SItemUniqueId>;
	public var activeSetIndex : int;
	default activeSetIndex = 1;

	protected function isEquipped( item : SItemUniqueId ) : bool
	{
		return false;
	}

	public function GetInventoryFlashArray( out flashArray : CScriptedFlashArray, flashObject : CScriptedFlashObject ) : void
	{
		displayedItems.Clear();
		super.GetInventoryFlashArray( flashArray, flashObject );
	}

	public function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject ) : void
	{
		var slotIdx : int;
		var chargesCount, maxCharges : int;
		var chargesStr : string;
		var locName : string;

		super.SetInventoryFlashObjectForItem( item, flashObject );

		displayedItems.PushBack( item );

		slotIdx = ModPotionSet_GetPotionSlotIndex( item, activeSetIndex );
		chargesCount = _inv.SingletonItemGetAmmo( item );
		maxCharges = _inv.SingletonItemGetMaxAmmo( item );
		locName = GetLocStringByKeyExt( _inv.GetItemLocalizedNameByUniqueID( item ) );

		flashObject.SetMemberFlashInt( "equipped", 0 );
		flashObject.SetMemberFlashBool( "disableAction", false );
		flashObject.SetMemberFlashBool( "cantEquip", false );

		if ( slotIdx > 0 )
		{
			flashObject.SetMemberFlashBool( "highlighted", true );
			chargesStr = "#" + slotIdx;
			flashObject.SetMemberFlashString( "charges", chargesStr );
			flashObject.SetMemberFlashString( "itemName", "[#" + slotIdx + "] " + locName + " (" + chargesCount + "/" + maxCharges + ")" );
		}
		else
		{
			flashObject.SetMemberFlashBool( "highlighted", false );
			flashObject.SetMemberFlashString( "itemName", locName + " (" + chargesCount + "/" + maxCharges + ")" );
		}
	}
}

exec function potionset_drink( optional setIdx : int )
{
	if ( setIdx <= 0 )
	{
		setIdx = 1;
	}
	ModPotionSet_DrinkSet( setIdx );
}

exec function potionset_drink1()
{
	ModPotionSet_DrinkSet( 1 );
}

exec function potionset_drink2()
{
	ModPotionSet_DrinkSet( 2 );
}

exec function potionset_clear( optional setIdx : int )
{
	if ( setIdx <= 0 )
	{
		ModPotionSet_ClearSet( 1 );
		ModPotionSet_ClearSet( 2 );
	}
	else
	{
		ModPotionSet_ClearSet( setIdx );
	}
}
