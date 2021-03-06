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
    <div class="panel-body">
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Id' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-2">
                <input type="text" class="input fixed-width-sm" id='id_mp_carrier_import_type' value="0" disabled>
            </div>
        </div>
        <div class="row"> 
            <div class="col-md-3 text-right">
                <label>{l s='Name' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-6">
                <input type="text" class="input" id='name_type'>
            </div>
        </div>
    <div class="panel-footer">
        <button type="button" class="btn btn-default pull-right" id="btn-save-config-type">
            <i class="process-icon-save"></i>
            {l s='Save' mod='mpcarrierimport'}
        </button>
    </div>
</div>
        