{*
* 2007-2015 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author Massimiliano Palermo <info@mpsoft.it>
*  @copyright  2017-2020 Digital Solutions®
*  @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of Massimiliano Palermo, mpsoft®
*}

<div class="panel">
     <div class="panel-heading" style="overflow: hidden; height: auto;">
        <div class="row">
            <div class="col-md-12">
                <small class='color-blue'>
                    {l s='To compile correctly reference, tracking and date columns, insert column number with "c" prefix.' mod='mpcarrierimport'}
                    {l s='Example to insert columns 3 5 and 9 write c3c5c9.' mod='mpcarrierimport'}
                </small>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <small class='color-green'>
                    {l s='If columns value have zeroes, insert zeroes quantity with "d" prefix.' mod='mpcarrierimport'}
                    {l s='Example to insert columns 3 with 4 zeroes 5 with 2 zeores and 9 write c3d5c5d4c9.' mod='mpcarrierimport'}
                </small>
            </div>
        </div>
    </div>
    <div class="panel-body">
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Id' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-2">
                <input type="text" class="input fixed-width-sm" id='id_mp_carrier_import' value="0" disabled>
            </div>
        </div>
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Name' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-6">
                <input type="text" class="input" id='carrier_name'>
            </div>
        </div>
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Import type' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-3">
                <select class="input select chosen-single" id='id_mp_carrier_import_type' data-placeholder="{l s='Select an import type' mod='mpcarrierimport'}">
                    <option/>
                    {foreach $list_import_types as $type}
                        <option value="{$type.id_mp_carrier_import_type}">{$type.name}</option>
                    {/foreach}
                </select>
            </div>
        </div>
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Order state' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-6">
                <select class="input select chosen-single" id='id_order_state' data-placeholder="{l s='Select an order state' mod='mpcarrierimport'}">
                    <option/>
                    {foreach $list_order_states as $order_state}
                        <option value="{$order_state.id_order_state}">{$order_state.name}</option>
                    {/foreach}
                </select>
            </div>
        </div>
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Page link' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-6">
                <input type="text" class="input" id='web_link'>
            </div>
        </div>
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Order reference colums' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-6">
                <input type="text" class="input fixed-width-xxl" id='col_order_reference'>
            </div>
        </div>
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Tracking id columns' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-6">
                <input type="text" class="input fixed-width-xxl" id='col_tracking_id'>
            </div>
        </div>
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Delivered date columns' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-6">
                <input type="text" class="input fixed-width-xxl" id='col_delivered_date'>
            </div>
        </div>
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Column separator' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-6">
                <input type="text" class="input fixed-width-xxl" id='column_separator'>
            </div>
        </div>
    </div>
    <div class="panel-footer">
        <button type="button" class="btn btn-default pull-right" id="btn-save-config">
            <i class="process-icon-save"></i>
            {l s='Save' mod='mpcarrierimport'}
        </button>
    </div>
</div>
        