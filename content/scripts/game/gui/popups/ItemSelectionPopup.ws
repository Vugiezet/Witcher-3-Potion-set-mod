/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EItemSelectionPopupMode
{
	EISPM_Default,
	EISPM_ArmorStand,
	EISPM_SwordStand,
	EISPM_Painting,	
	
	EISPM_RadialMenuSlot1,
	EISPM_RadialMenuSlot2,
	EISPM_RadialMenuSlot3,
	EISPM_RadialMenuSlot4,
	EISPM_RadialMenuSteelOil,
	EISPM_RadialMenuSilverOil,
	EISPM_PotionSet,
	
}


class W3ItemSelectionPopupData extends CObject
{
	var targetInventory : CInventoryComponent;
	var filterTagsList : array<name>;
	var filterForbiddenTagsList : array<name>;	
	var categoryFilterList : array<name>;	
	var collectorTag : name;
	var targetItems : array<name>;
	var selectionMode : EItemSelectionPopupMode;
	var overrideQuestItemRestrictions : bool;
	var checkTagsOR : bool; 
	var invMenuRef : CR4InventoryMenu;
}

class CR4ItemSelectionPopup extends CR4PopupBase
{
	var m_DataObject     : W3ItemSelectionPopupData;
	var m_playerInv      : W3GuiSelectItemComponent;
	var m_containerInv   : W3GuiContainerInventoryComponent;
	var m_containerOwner : CGameplayEntity;
	var m_selectedItemCategory : int;	
	default m_selectedItemCategory = 0;

	
	private var m_fxSetItemDescription 		: CScriptedFlashFunction;
	private var m_fxSetCategory 			: CScriptedFlashFunction;
	private var m_fxShowCategoryButtons 	: CScriptedFlashFunction;
	private var m_fxDeselectItem			: CScriptedFlashFunction;
	private var m_fxHandleForeignInputEvent	: CScriptedFlashFunction;
	private var m_lastSelectedItemId		: SItemUniqueId;
	private var m_selectedIndex				: int;
	private var m_isUpdatingData			: bool;
	private var m_openTimeMs				: int;
	private var m_lastToggleTimeMs			: int;
	private var m_lastMouseClickItemId		: SItemUniqueId;
	private var m_lastMouseClickTimeMs		: int;
	public var m_activeSetIndex				: int;
	default m_activeSetIndex = 1;
	public var m_isClosing					: bool;
	default m_isClosing = false;

	public function IsClosing() : bool { return m_isClosing; }
	var m_potionInv, m_mutagenInv, m_edibleInv : W3GuiSelectItemComponent;
	var forbiddenTags, forbiddenTagsPotion, tagsP, tagsM, tagsE : array<name>;
	
	
	event  OnConfigUI()
	{
		var potionSetComp : W3GuiPotionSetSelectComponent;

		super.OnConfigUI();
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		m_DataObject = (W3ItemSelectionPopupData)GetPopupInitData();		
		
		if (!m_DataObject)
		{
			ClosePopup();
		}
		
		if ( m_DataObject && m_DataObject.selectionMode != EISPM_PotionSet && theInput.IsMousePresent() )
		{
			theGame.MoveMouseTo(0.5, 0.5);
		}
		
		
		m_fxSetItemDescription = GetPopupFlash().GetMemberFlashFunction( "setItemDescription" );
		m_fxSetCategory = GetPopupFlash().GetMemberFlashFunction( "setCategory" );
		m_fxShowCategoryButtons = GetPopupFlash().GetMemberFlashFunction( "showCategoryButtons" );
		m_fxDeselectItem = GetPopupFlash().GetMemberFlashFunction( "deselectItem" );
		m_fxHandleForeignInputEvent = GetPopupFlash().GetMemberFlashFunction( "handleForeignInputEvent" );
		m_openTimeMs = theGame.GetLocalTimeAsMilliseconds();
		m_lastToggleTimeMs = m_openTimeMs;
		m_selectedIndex = 0;
		m_isUpdatingData = false;
		
		if( m_DataObject.selectionMode == EISPM_RadialMenuSlot1 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSlot2 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSlot3 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSlot4 )
		{	
			tagsP.PushBack('Potion');
			tagsM.PushBack('Mutagen');
			tagsE.PushBack('Edibles');
		
			forbiddenTags.PushBack('NoEquip');
			forbiddenTagsPotion.PushBack('NoEquip');
			forbiddenTagsPotion.PushBack('Mutagen');
			forbiddenTagsPotion.PushBack('Edibles');
			
			m_potionInv = new W3GuiSelectItemComponent in this;
			m_potionInv.Initialize( thePlayer.GetInventory() );
			m_potionInv.filterTagList = tagsP;
			m_potionInv.filterForbiddenTagList = forbiddenTagsPotion;
			m_potionInv.ignorePosition = true;
			m_potionInv.SetFilterType( IFT_None );
			
			m_potionInv.maxItemLimit = 80;
			
			m_mutagenInv = new W3GuiSelectItemComponent in this;
			m_mutagenInv.Initialize( thePlayer.GetInventory() );
			m_mutagenInv.filterTagList = tagsM;
			m_mutagenInv.filterForbiddenTagList = forbiddenTags;
			m_mutagenInv.ignorePosition = true;
			m_mutagenInv.checkTagsOR = true;
			m_mutagenInv.SetFilterType( IFT_None );
			
			m_mutagenInv.maxItemLimit = 80;
			
			m_edibleInv = new W3GuiSelectItemComponent in this;
			m_edibleInv.Initialize( thePlayer.GetInventory() );
			m_edibleInv.filterTagList = tagsE;
			m_edibleInv.filterForbiddenTagList = forbiddenTags;
			m_edibleInv.ignorePosition = true;
			m_edibleInv.checkTagsOR = true;
			m_edibleInv.SetFilterType( IFT_None );
			
			m_edibleInv.maxItemLimit = 80;
			
			m_playerInv = m_potionInv;
			m_fxSetCategory.InvokeSelfOneArg( FlashArgString( GetLocStringByKeyExt( "panel_alchemy_tab_potions" ) ) );
			m_fxShowCategoryButtons.InvokeSelfOneArg( FlashArgBool(true) );
		}
		else if( m_DataObject.selectionMode == EISPM_PotionSet )
		{
			tagsP.PushBack('Potion');
			forbiddenTagsPotion.PushBack('NoEquip');
			forbiddenTagsPotion.PushBack('Mutagen');
			forbiddenTagsPotion.PushBack('Edibles');
			
			m_activeSetIndex = 1;
			potionSetComp = new W3GuiPotionSetSelectComponent in this;
			potionSetComp.activeSetIndex = m_activeSetIndex;
			m_playerInv = potionSetComp;
			m_playerInv.Initialize( thePlayer.GetInventory() );
			m_playerInv.filterTagList = tagsP;
			m_playerInv.filterForbiddenTagList = forbiddenTagsPotion;
			m_playerInv.ignorePosition = true;
			m_playerInv.SetFilterType( IFT_None );
			m_playerInv.maxItemLimit = 80;
			
			m_fxSetCategory.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetHeaderText( m_activeSetIndex ) ) );
			m_fxShowCategoryButtons.InvokeSelfOneArg( FlashArgBool(true) );
			m_fxSetItemDescription.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetPopupDescriptionText( GetInvalidUniqueId(), m_activeSetIndex ) ) );
		}
		else
		{
			m_fxShowCategoryButtons.InvokeSelfOneArg( FlashArgBool(false) );		
			
			m_playerInv = new W3GuiSelectItemComponent in this;
			m_playerInv.Initialize( thePlayer.GetInventory() );
			m_playerInv.filterTagList = m_DataObject.filterTagsList;
			m_playerInv.filterForbiddenTagList = m_DataObject.filterForbiddenTagsList;
			m_playerInv.ignorePosition = true; 
			m_playerInv.checkTagsOR = m_DataObject.checkTagsOR; 
		}
		
		switch( m_DataObject.selectionMode )
		{
			case EISPM_Default :
			{
				
				m_playerInv.SetFilterType( IFT_QuestItems );
			}
			break;
			
			case EISPM_ArmorStand :
			{
				
				m_playerInv.SetFilterType( IFT_Armors );
				
				if( m_DataObject.categoryFilterList.Size() > 0 )
				{
					m_playerInv.SetItemCategoryType( m_DataObject.categoryFilterList[m_selectedItemCategory] );	
				}
				else
				{
					m_playerInv.SetItemCategoryType( 'armor' );
				}
				
				
				m_playerInv.SetOverrideQuestItemFilters( m_DataObject.overrideQuestItemRestrictions );
			}
			break;
			
			case EISPM_SwordStand :
			{
				
				m_playerInv.SetFilterType( IFT_Weapons );
				m_playerInv.SetOverrideQuestItemFilters( m_DataObject.overrideQuestItemRestrictions );			
			}
			break;	
			
			case EISPM_Painting :
			{
				
				m_playerInv.SetFilterType( IFT_None );
				m_playerInv.SetOverrideQuestItemFilters( m_DataObject.overrideQuestItemRestrictions );			
			}
			break;
			
			
			case EISPM_RadialMenuSlot1 :
			case EISPM_RadialMenuSlot2 :
			case EISPM_RadialMenuSlot3 :
			case EISPM_RadialMenuSlot4 :
			case EISPM_RadialMenuSteelOil :
			case EISPM_RadialMenuSilverOil :
			case EISPM_PotionSet :
			{
				m_playerInv.SetFilterType( IFT_None );	
			}
			break;
			
		}
		
		
		m_containerOwner = (CGameplayEntity)theGame.GetEntityByTag( m_DataObject.collectorTag );
		
		m_isUpdatingData = true;
		UpdateData();
		m_isUpdatingData = false;
		
		if ( m_DataObject.selectionMode == EISPM_PotionSet )
		{
			if ( GetDisplayedItemsCount() > 0 )
			{
				m_selectedIndex = 0;
				m_lastSelectedItemId = GetDisplayedItemAt( 0 );
			}
			m_fxSetCategory.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetHeaderText( m_activeSetIndex ) ) );
			m_fxSetItemDescription.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetPopupDescriptionText( m_lastSelectedItemId, m_activeSetIndex ) ) );
		}
		
		if ( m_DataObject.selectionMode != EISPM_PotionSet )
		{
			m_guiManager.RequestMouseCursor(true);
			theGame.ForceUIAnalog(true);
			theGame.Pause("ItemSelectionPopup");
		}
	}
	
	event  OnCloseSelectionPopup()
	{
		ClosePopup();
	}
	
	event  OnCallSelectItem(itemId : SItemUniqueId)
	{
		var len, i : int;
		
		switch( m_DataObject.selectionMode )
		{
			
			case EISPM_Default :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					len = m_DataObject.targetItems.Size();
					for (i = 0; i < len; i=i+1 )
					{
						
						if (m_DataObject.targetItems[i] == m_playerInv.GetItemName(itemId))
						{
							thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
							break;
						}
					}
					ClosePopup();
				}
			}
			break;
			
			
			case EISPM_ArmorStand :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
					
					while( m_selectedItemCategory <= m_DataObject.categoryFilterList.Size() )
					{
						if(TryToOpenNextCategory())
						{
							return true;
						}
					}
					
					ClosePopup();
				}
			}
			break;
			
			
			case EISPM_SwordStand :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
					ClosePopup();
				}
			}
			break;
			
			
			case EISPM_Painting :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
					ClosePopup();
				}
			}
			break;		
			
			
			case EISPM_RadialMenuSlot1 :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.EquipItem(itemId, EES_Potion1);
					GetWitcherPlayer().EnableRadialInput();
					ClosePopup();		
				}
			}
			break;
			
			case EISPM_RadialMenuSlot2 :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.EquipItem(itemId, EES_Potion2);
					GetWitcherPlayer().EnableRadialInput();
					ClosePopup();		
				}
			}
			break;
			
			case EISPM_RadialMenuSlot3 :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.EquipItem(itemId, EES_Potion3);
					GetWitcherPlayer().EnableRadialInput();
					ClosePopup();		
				}
			}
			break;
			
			case EISPM_RadialMenuSlot4 :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.EquipItem(itemId, EES_Potion4);
					GetWitcherPlayer().EnableRadialInput();
					ClosePopup();		
				}
			}
			break;
			
			case EISPM_RadialMenuSteelOil :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.ApplyOil(itemId, GetWitcherPlayer().GetEquippedSword( true ));
					GetWitcherPlayer().EnableRadialInput();
					theSound.SoundEvent( "gui_preparation_potion" );
					ClosePopup();		
				}
			}
			break;
			
			case EISPM_RadialMenuSilverOil :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.ApplyOil(itemId, GetWitcherPlayer().GetEquippedSword( false ));
					GetWitcherPlayer().EnableRadialInput();
					theSound.SoundEvent( "gui_preparation_potion" );
					ClosePopup();		
				}
			}
			break;
			
			case EISPM_PotionSet :
			{
				TogglePotionItem( itemId );
			}
			break;
			
		}
	}
	
	event  OnInventoryItemSelected(itemId : SItemUniqueId)
	{
		if ( m_DataObject && m_DataObject.selectionMode == EISPM_PotionSet && thePlayer.GetInventory().IsIdValid(itemId) )
		{
			m_lastSelectedItemId = itemId;
			SyncSelectedIndex( itemId );
			m_fxSetItemDescription.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetPopupDescriptionText( itemId, m_activeSetIndex ) ) );
		}
	}
	
	event  OnClosingPopup()
	{


		m_isClosing = true;
		if ( m_DataObject && m_DataObject.selectionMode != EISPM_PotionSet )
		{
			theGame.Unpause("ItemSelectionPopup");
		}
		
		if (m_containerInv)
		{
			delete m_containerInv;
		}
		
		if (m_playerInv)
		{
			delete m_playerInv;
		}
		
		if (m_DataObject && m_DataObject.selectionMode == EISPM_PotionSet)
		{
			theInput.RestoreContext( 'EMPTY_CONTEXT', true );
			if (m_DataObject.invMenuRef)
			{
				m_DataObject.invMenuRef.OnPotionSetPopupClosed();
			}
		}
		else
		{
			theInput.RestoreContext( 'EMPTY_CONTEXT', true );
			theGame.ForceUIAnalog(false);
			m_guiManager.RequestMouseCursor(false);
		}
		
		
		if (m_potionInv)
			delete m_potionInv;
			
		if (m_mutagenInv)
			delete m_mutagenInv;
			
		if (m_edibleInv)
			delete m_edibleInv;
		
		if( m_DataObject.selectionMode == EISPM_RadialMenuSteelOil 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSilverOil 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSlot1 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSlot2 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSlot3 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSlot4 )
			GetWitcherPlayer().EnableRadialInput();
		
		
		super.OnClosingPopup();
	}
	
	
	private function ClearPopupSelection()
	{
		m_playerInv.SetItemCategoryType( 'none' );
		UpdateData();
	}
	
	
	private function TryToOpenNextCategory() : bool
	{
		var stand : W3HouseDecorationBase;
		
		m_selectedItemCategory += 1;
		ClearPopupSelection();
		
		stand = (W3HouseDecorationBase) m_containerOwner;
		
		
		if( !stand )
		{
			return false;
		}
		
		
		if( stand.GetHasSleevlessArmor() && m_DataObject.categoryFilterList[m_selectedItemCategory] == 'gloves' )
		{
			return false;
		}
		
		
		if( !thePlayer.GetInventory().GetHasValidDecorationItems( thePlayer.inv.GetItemsByCategory( m_DataObject.categoryFilterList[m_selectedItemCategory] ), stand ) )
		{
			return false;
		}
		
		m_playerInv.SetItemCategoryType( m_DataObject.categoryFilterList[m_selectedItemCategory] );
		UpdateData();		
		
		return true;
	}
	
	
	private function UpdateData():void
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();		
		m_playerInv.GetInventoryFlashArray(l_flashArray, l_flashObject);		
		m_flashValueStorage.SetFlashArray( "repair.grid.player", l_flashArray );
	}
	
	
	event OnChangeCategory( id : int )
	{
		var locString : string;
		var potionSetComp : W3GuiPotionSetSelectComponent;
	
		if( m_DataObject.selectionMode == EISPM_RadialMenuSlot1 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSlot2 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSlot3 
			|| m_DataObject.selectionMode == EISPM_RadialMenuSlot4 )
		{	
			m_selectedItemCategory += id;
			if (m_selectedItemCategory < 0)
				m_selectedItemCategory = 2;
			else if (m_selectedItemCategory > 2)
				m_selectedItemCategory = 0;
			
			switch(m_selectedItemCategory)
			{
				case 0:
					locString = GetLocStringByKeyExt( "panel_alchemy_tab_potions" );	
					m_playerInv = m_potionInv;
					break;
				case 1:
					locString = GetLocStringByKeyExt( "panel_inventory_filter_type_decoctions" );	
					m_playerInv = m_mutagenInv;
					break;
				case 2:
					locString = GetLocStringByKeyExt( "item_category_edibles" );	
					m_playerInv = m_edibleInv;
					break;
			}
			
			m_fxDeselectItem.InvokeSelf();
			m_fxSetCategory.InvokeSelfOneArg( FlashArgString( locString ) );
			UpdateData();
			
			return true;
		}
		else if( m_DataObject.selectionMode == EISPM_PotionSet )
		{
			m_lastToggleTimeMs = theGame.GetLocalTimeAsMilliseconds();
			if ( m_activeSetIndex == 1 )
			{
				m_activeSetIndex = 2;
			}
			else
			{
				m_activeSetIndex = 1;
			}

			potionSetComp = (W3GuiPotionSetSelectComponent)m_playerInv;
			if ( potionSetComp )
			{
				potionSetComp.activeSetIndex = m_activeSetIndex;
			}

			theSound.SoundEvent( "gui_global_highlight" );
			m_isUpdatingData = true;
			m_fxDeselectItem.InvokeSelf();
			UpdateData();
			m_isUpdatingData = false;
			m_fxSetCategory.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetHeaderText( m_activeSetIndex ) ) );
			m_fxSetItemDescription.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetPopupDescriptionText( m_lastSelectedItemId, m_activeSetIndex ) ) );
			
			return true;
		}
		
		return false;
	}
	
	event OnItemSelected( itemId : SItemUniqueId )
	{
		var uniqueDescription, valueString : string;
		var currentStat	: SAttributeTooltip;
		var itemStats : array<SAttributeTooltip>;
		var i, nowMs : int;
		
		if( m_DataObject.selectionMode == EISPM_RadialMenuSlot1 ||
			m_DataObject.selectionMode == EISPM_RadialMenuSlot2 ||
			m_DataObject.selectionMode == EISPM_RadialMenuSlot3 ||
			m_DataObject.selectionMode == EISPM_RadialMenuSlot4 )
		{
			uniqueDescription = GetLocStringByKeyExt( thePlayer.GetInventory().GetItemLocalizedDescriptionByUniqueID(itemId) );		
			m_fxSetItemDescription.InvokeSelfOneArg( FlashArgString( uniqueDescription ) );
		}
		else if( m_DataObject.selectionMode ==  EISPM_RadialMenuSteelOil || m_DataObject.selectionMode ==  EISPM_RadialMenuSilverOil )
		{		
			thePlayer.GetInventory().GetItemBaseStats(itemId, itemStats);		

			for( i = 0; i < itemStats.Size(); i += 1) 
			{
				currentStat = itemStats[i];	
				valueString = NoTrailZeros( RoundMath( currentStat.value * 100 ) ) + "% ";				
				uniqueDescription = valueString + currentStat.attributeName;
			}
			
			m_fxSetItemDescription.InvokeSelfOneArg( FlashArgString( uniqueDescription ) );
		}
		else if( m_DataObject.selectionMode == EISPM_PotionSet )
		{
			if ( !thePlayer.GetInventory().IsIdValid( itemId ) )
			{
				return false;
			}

			m_lastSelectedItemId = itemId;
			SyncSelectedIndex( itemId );

			nowMs = theGame.GetLocalTimeAsMilliseconds();
			if ( !m_isUpdatingData && theInput.LastUsedPCInput() && Abs( nowMs - m_openTimeMs ) > 250 )
			{
				if ( m_lastMouseClickItemId == itemId && ( nowMs - m_lastMouseClickTimeMs ) <= 450 && ( nowMs - m_lastMouseClickTimeMs ) > 60 )
				{
					m_lastMouseClickTimeMs = 0;
					m_lastMouseClickItemId = GetInvalidUniqueId();
					TogglePotionItem( itemId );
					return true;
				}
				else
				{
					m_lastMouseClickItemId = itemId;
					m_lastMouseClickTimeMs = nowMs;
				}
			}

			uniqueDescription = ModPotionSet_GetPopupDescriptionText( itemId, m_activeSetIndex );
			m_fxSetItemDescription.InvokeSelfOneArg( FlashArgString( uniqueDescription ) );
		}
	}

	private function GetDisplayedItemsCount() : int
	{
		var potionSetComp : W3GuiPotionSetSelectComponent;
		potionSetComp = (W3GuiPotionSetSelectComponent)m_playerInv;
		if ( potionSetComp )
		{
			return potionSetComp.displayedItems.Size();
		}
		return 0;
	}

	private function GetDisplayedItemAt( idx : int ) : SItemUniqueId
	{
		var potionSetComp : W3GuiPotionSetSelectComponent;
		potionSetComp = (W3GuiPotionSetSelectComponent)m_playerInv;
		if ( potionSetComp && idx >= 0 && idx < potionSetComp.displayedItems.Size() )
		{
			return potionSetComp.displayedItems[idx];
		}
		return GetInvalidUniqueId();
	}

	private function SyncSelectedIndex( itemId : SItemUniqueId )
	{
		var potionSetComp : W3GuiPotionSetSelectComponent;
		var i : int;

		potionSetComp = (W3GuiPotionSetSelectComponent)m_playerInv;
		if ( !potionSetComp )
		{
			return;
		}
		for ( i = 0; i < potionSetComp.displayedItems.Size(); i += 1 )
		{
			if ( potionSetComp.displayedItems[i] == itemId )
			{
				m_selectedIndex = i;
				return;
			}
		}
	}

	private function MoveSelection( delta : int )
	{
		var count : int;
		var newItem : SItemUniqueId;

		count = GetDisplayedItemsCount();
		if ( count <= 0 )
		{
			return;
		}

		m_selectedIndex += delta;
		if ( m_selectedIndex < 0 )
		{
			m_selectedIndex = 0;
		}
		else if ( m_selectedIndex >= count )
		{
			m_selectedIndex = count - 1;
		}

		newItem = GetDisplayedItemAt( m_selectedIndex );
		if ( thePlayer.GetInventory().IsIdValid( newItem ) )
		{
			m_lastSelectedItemId = newItem;
			theSound.SoundEvent( "gui_global_highlight" );
			m_fxSetItemDescription.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetPopupDescriptionText( newItem, m_activeSetIndex ) ) );
		}
	}

	public function TogglePotionItem( itemId : SItemUniqueId )
	{
		var res, nowMs : int;

		if ( !thePlayer.GetInventory().IsIdValid( itemId ) )
		{
			if ( thePlayer.GetInventory().IsIdValid( m_lastSelectedItemId ) )
			{
				itemId = m_lastSelectedItemId;
			}
			else if ( GetDisplayedItemsCount() > 0 )
			{
				itemId = GetDisplayedItemAt( m_selectedIndex );
			}
		}

		if ( !thePlayer.GetInventory().IsIdValid( itemId ) )
		{
			theSound.SoundEvent( "gui_global_denied" );
			return;
		}

		nowMs = theGame.GetLocalTimeAsMilliseconds();
		if ( Abs( nowMs - m_lastToggleTimeMs ) < 120 )
		{
			return;
		}
		m_lastToggleTimeMs = nowMs;

		m_lastSelectedItemId = itemId;
		SyncSelectedIndex( itemId );

		res = ModPotionSet_TogglePotion( itemId, m_activeSetIndex );
		if ( res > 0 )
		{
			theSound.SoundEvent( "gui_preparation_potion" );
		}
		else if ( res == 0 )
		{
			theSound.SoundEvent( "gui_inventory_other_back" );
		}
		else
		{
			theSound.SoundEvent( "gui_global_denied" );
		}

		m_isUpdatingData = true;
		if ( theInput.LastUsedPCInput() )
		{
			m_fxDeselectItem.InvokeSelf();
		}
		UpdateData();
		m_isUpdatingData = false;

		m_fxSetCategory.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetHeaderText( m_activeSetIndex ) ) );
		m_fxSetItemDescription.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetPopupDescriptionText( itemId, m_activeSetIndex ) ) );
	}

	public function ClearActiveSet()
	{
		ModPotionSet_ClearSet( m_activeSetIndex );
		theSound.SoundEvent( "gui_inventory_other_back" );
		m_isUpdatingData = true;
		m_fxDeselectItem.InvokeSelf();
		UpdateData();
		m_isUpdatingData = false;
		m_fxSetCategory.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetHeaderText( m_activeSetIndex ) ) );
		m_fxSetItemDescription.InvokeSelfOneArg( FlashArgString( ModPotionSet_GetPopupDescriptionText( m_lastSelectedItemId, m_activeSetIndex ) ) );
	}

	public function HandleForeignInput( type : string, keyCode : int, inputValue : string, navEquivalent : string )
	{
		if ( m_fxHandleForeignInputEvent )
		{
			m_fxHandleForeignInputEvent.InvokeSelfFourArgs( FlashArgString( type ), FlashArgInt( keyCode ), FlashArgString( inputValue ), FlashArgString( navEquivalent ) );
		}

		if ( !m_DataObject || m_DataObject.selectionMode != EISPM_PotionSet )
		{
			return;
		}

		if ( type == "keyDown" )
		{
			if ( keyCode == IK_Left || keyCode == IK_A || keyCode == IK_Pad_DigitLeft || navEquivalent == "left" )
			{
				MoveSelection( -1 );
			}
			else if ( keyCode == IK_Right || keyCode == IK_D || keyCode == IK_Pad_DigitRight || navEquivalent == "right" )
			{
				MoveSelection( 1 );
			}
			else if ( keyCode == IK_Up || keyCode == IK_W || keyCode == IK_Pad_DigitUp || navEquivalent == "up" )
			{
				MoveSelection( -6 );
			}
			else if ( keyCode == IK_Down || keyCode == IK_S || keyCode == IK_Pad_DigitDown || navEquivalent == "down" )
			{
				MoveSelection( 6 );
			}
		}
		else if ( type == "keyUp" )
		{
			if ( keyCode == IK_E || keyCode == IK_Enter || keyCode == IK_Space || keyCode == IK_Pad_A_CROSS || navEquivalent == "enter-gamepad_A" )
			{
				TogglePotionItem( m_lastSelectedItemId );
			}
			else if ( keyCode == IK_1 || keyCode == IK_3 || keyCode == IK_Pad_LeftShoulder || keyCode == IK_Pad_RightShoulder || navEquivalent == "gamepad_L1" || navEquivalent == "gamepad_R1" )
			{
				OnChangeCategory( 1 );
			}
			else if ( keyCode == IK_R || keyCode == IK_Pad_X_SQUARE || navEquivalent == "gamepad_X" )
			{
				ClearActiveSet();
			}
			else if ( keyCode == IK_Escape || keyCode == IK_Backspace || keyCode == IK_T || keyCode == IK_Pad_B_CIRCLE || navEquivalent == "escape-gamepad_B" )
			{
				ClosePopup();
			}
		}
	}

	public function HandleMenuInput( NavCode : string, KeyCode : int, ActionId : int )
	{
		if ( !m_DataObject || m_DataObject.selectionMode != EISPM_PotionSet )
		{
			return;
		}

		if ( NavCode == "enter-gamepad_A" || KeyCode == IK_E || KeyCode == IK_Enter || KeyCode == IK_Space || KeyCode == IK_Pad_A_CROSS )
		{
			TogglePotionItem( m_lastSelectedItemId );
		}
		else if ( NavCode == "escape-gamepad_B" || KeyCode == IK_Escape || KeyCode == IK_Backspace || KeyCode == IK_Pad_B_CIRCLE )
		{
			ClosePopup();
		}
		else if ( NavCode == "gamepad_L1" || NavCode == "gamepad_R1" || KeyCode == IK_1 || KeyCode == IK_3 || KeyCode == IK_Pad_LeftShoulder || KeyCode == IK_Pad_RightShoulder )
		{
			OnChangeCategory( 1 );
		}
		else if ( NavCode == "gamepad_X" || KeyCode == IK_R || KeyCode == IK_Pad_X_SQUARE )
		{
			ClearActiveSet();
		}
		else if ( NavCode == "left" )
		{
			MoveSelection( -1 );
		}
		else if ( NavCode == "right" )
		{
			MoveSelection( 1 );
		}
		else if ( NavCode == "up" )
		{
			MoveSelection( -6 );
		}
		else if ( NavCode == "down" )
		{
			MoveSelection( 6 );
		}
	}
	
}
