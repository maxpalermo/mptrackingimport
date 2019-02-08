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
<input type="hidden" id='change-status' value="{$id_order_state_change}">
<table class="table table-responsive table-hover table-bordered" style="width:auto; margin: 10px auto;">
    <thead>
        <tr>
            <th colspan="7">
                <div class="row"> 
                    <div class="badge" style="width: 100%">
                        {l s='Total'}: {count($rows)}
                    </div>
                </div> 
            </th>
        </tr>
        <tr>
            <th><input type="checkbox" id="check-all" checked></th>
            <th>{l s='Order reference' mod='mpcarrierimport'}</th>
            <th>{l s='Customer' mod='mpcarrierimport'}</th>
            <th>{l s='Date' mod='mpcarrierimport'}</th>
            <th>{l s='Tracking id' mod='mpcarrierimport'}</th>
            <th>{l s='Delivered date' mod='mpcarrierimport'}</th>
            <th style="width: 10em;">{l s='Web link' mod='mpcarrierimport'}</th>
        </tr>
    </thead>
    <tbody>
        {foreach $rows as $row}
            <tr>
                <td><input type="checkbox" name="check-row" {if $row.exists>0}checked{/if}></td>
                <td>{$row.reference}</td>
                <td>{$row.customer}</td>
                <td>{$row.date}</td>
                <td>{$row.tracking_id}</td>
                <td style="text-align: center;">
                    {if $row.delivered_date}
                        {$row.delivered_date}
                    {else}
                        --
                    {/if}
                </td>
                <td>
                    <a href="{$row.web_link}" class="btn btn-default" target="_blank">
                        <i class="icon icon-link"></i>&nbsp;{l s='Tracking' mod='mpcarrierimport'} 
                    </a> 
                </td>
            </tr>
        {/foreach}
    </tbody>
    <tfoot>
        <tr>
            <th colspan="7">
                <div class="row"> 
                    <div class="col-md-12">
                        <hr>
                    </div>
                </div>
            </th>
        </tr>
    </tfoot>
</table>