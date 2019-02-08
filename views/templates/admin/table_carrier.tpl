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

<table class="table table-responsive table-hover table-bordered">
    <thead>
        <tr>
            <th>{l s='Id' mod='mpcarrierimport'}</th>
            <th>{l s='Name' mod='mpcarrierimport'}</th>
            <th>{l s='Type' mod='mpcarrierimport'}</th>
            <th>{l s='Col Sep' mod='mpcarrierimport'}</th>
            <th>{l s='Web link' mod='mpcarrierimport'}</th>
            <th>{l s='Order ref.' mod='mpcarrierimport'}</th>
            <th>{l s='Tracking' mod='mpcarrierimport'}</th>
            <th>{l s='Delivered' mod='mpcarrierimport'}</th>
            <th>{l s='Order State' mod='mpcarrierimport'}</th>
        </tr>
    </thead>
    <tbody>
        {foreach $list_carriers as $row}
            <tr>
                <td>{$row.id_mp_carrier_import}</td>
                <td>{$row.carrier_name}</td>
                <td>{$row.import_type}</td>
                <td>{$row.column_separator}</td>
                <td>{$row.web_link}</td>
                <td>{$row.col_order_reference}</td>
                <td>{$row.col_tracking_id}</td>
                <td>{$row.col_delivered_date}</td>
                <td>{$row.order_state}</td>
            </tr>
        {/foreach}
    </tbody>
    <tfoot>

    </tfoot>
</table>