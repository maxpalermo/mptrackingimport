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

<style>
    .color-red
    {
        color: #BB7979 !important;
    }
    .color-green
    {
        color: #4eb357 !important;
    }
    .color-orange
    {
        color: #fbbb22 !important;
    }
    .color-blue
    {
        color: #25b9d7 !important;
    }
    .color-white
    {
        color: #fefefe;
    }
    .map-embedded
    {
        width: 100%;
        height: 100%;
    }
    .div-col
    {
        display: inline-block !important;
        padding-left: 6px !important;
    }
    .panel >.panel-body>.row
    {
        margin-bottom: 12px !important;
    }
    .table tr:hover td
    {
        cursor: pointer;
    }
</style>

<div class="row" id="config">
    <!--Nav content-->
    <ul class='nav nav-tabs' id="tabConfig">
        <li class="active" data-type="config-carrier">
            <a href="#tabPaneCarrier" onclick='javascript:activatePane();'>
                <i class="icon icon-truck"></i>&nbsp;{l s='Carrier configuration' mod='mpcarrierimport'}
            </a>
        </li>
        <li data-type="config-import">
            <a href="#tabPaneType" onclick='javascript:activatePane();'>
                <i class="icon icon-cogs"></i>&nbsp;{l s='Import type configuration' mod='mpcarrierimport'}
            </a>
        </li>
    </ul>
    <!--Tab content-->
    <div class="tab-content panel">
        <!--Tabs-->
        <div class="tab-pane active" id="tabPaneCarrier">
            {include file=$tab_carrier}
            <div class="row">
                <div class="col-md-12" id="table-carrier-content">
                    {if !empty($list_carriers)}
                        {include file=$table_carrier_tpl}
                    {/if}
                </div>
            </div>
        </div>
        <div class="tab-pane" id="tabPaneType">
            {include file=$tab_type}
            <div class="row">
                <div class="col-md-12" id="table-type-content">
                    {if !empty($list_import_types)}
                        {include file=$table_type_tpl}
                    {/if}
                </div>
            </div>
        </div>
    </div>
</div>
                    
<script type="text/javascript">
    $(document).ready(function(){
        activatePane();
        bind();
    });
    
    function bind()
    {
        $('.chosen-single').chosen();
        $('#btn-save-config').on('click', function(){
            var obj = {
                'id_mp_carrier_import': $('#id_mp_carrier_import').val(),
                'carrier_name': $('#carrier_name').val(),
                'id_mp_carrier_import_type': $('#id_mp_carrier_import_type').chosen().val(),
                'id_order_state': $('#id_order_state').chosen().val(),
                'column_separator': $('#column_separator').val(),
                'web_link': $('#web_link').val(),
                'col_order_reference': $('#col_order_reference').val(),
                'col_tracking_id': $('#col_tracking_id').val(),
                'col_delivered_date': $('#col_delivered_date').val(),
            };
            
            if (confirm("{l s='Are you sure you want to save this record?'}")) {
                $.ajax({
                    type: 'post',
                    dataType: 'json',
                    data:
                    {
                        ajax: true,
                        action: 'saveRecord',
                        obj: obj
                    },
                    success: function(response) {
                        if (response.errors.length) {
                            $(response.errors).each(function(){
                                $.growl.error({
                                    'title': '{l s='Error' mod='mpcarrierimport'}',
                                    'message': this
                                });
                            });
                            return false;
                        }
                        $(response.errors).each(function(){
                            $.growl.notice({
                                'title': '{l s='Operation Done' mod='mpcarrierimport'}',
                                'message': '{l s='Record saved.' mod='mpcarrierimport'}'
                            });
                        });
                        if (response.result) {
                            $('#table-carrier-content').html(response.tableHTML);
                        } else {
                           $.growl.error({
                                'title': '{l s='Error' mod='mpcarrierimport'}',
                                'message': '{l s='Error saving record.' mod='mpcarrierimport'}'
                            }); 
                        }
                    },
                    error: function(response) {
                        console.log(response);
                    }
                });
            }
        });
    }

    function activatePane()
    {
        event.preventDefault();
        var elem = document.activeElement;
        var type = $(elem).attr('data-type');
        var li = $(elem).closest('li');
        var nav = $(elem).closest('.nav');
        var tabs = $(nav).closest('.row').find('.tab-content');
        var div = $(elem).attr('href');
        $(nav).find('li').removeClass('active');
        $(li).addClass('active');
        $(tabs).find('div').removeClass('active');
        $(div).addClass('active');
    }
    
    function copyTextToClipboard(text) {
        var textArea = document.createElement("textarea");

        textArea.style.position = 'fixed';
        textArea.style.top = 0;
        textArea.style.left = 0;
        textArea.style.width = '2em';
        textArea.style.height = '2em';
        textArea.style.padding = 0;
        textArea.style.border = 'none';
        textArea.style.outline = 'none';
        textArea.style.boxShadow = 'none';
        textArea.style.background = 'transparent';
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.select();
        try {
            var successful = document.execCommand('copy');
            var msg = successful ? 'successful' : 'unsuccessful';
            console.log('Copying text command was ' + msg);
        } catch (err) {
            console.log('Oops, unable to copy');
        }
        document.body.removeChild(textArea);
    }
</script>   
