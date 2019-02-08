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
    #progress-wrp {
        border: 1px solid #0099CC;
        padding: 1px;
        position: relative;
        height: 30px;
        border-radius: 3px;
        margin: 10px;
        text-align: left;
        background: #fff;
        box-shadow: inset 1px 3px 6px rgba(0, 0, 0, 0.12);
    }

    #progress-wrp .progress-bar {
        height: 100%;
        border-radius: 3px;
        background-color: #4eb357;
        width: 0;
        box-shadow: inset 1px 1px 10px rgba(0, 0, 0, 0.11);
    }

    #progress-wrp .status {
        top: 3px;
        left: 50%;
        position: absolute;
        display: inline-block;
        color: #000000;
    }
    .badge-white
    {
        font-size: 8pt;
        border-radius: 2px;
        border: 1px solid #777777;
        padding: 3px;
        width: 4em;
        background-color: #fcfcfc;
        color: #555;
        text-shadow: 1px 1px 3px solid #777777;
        text-align: center;
        position: absolute;
        right: -4em;
    }
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
<div class="panel">
    <div class="panel-heading">
            <i class="icon icon-download"></i>&nbsp;{l s='Import Tracking' mod='mpcarrierimport'}
    </div>
    <div class="panel-body">
        <div class="row">
            <div class='col-md-3 text-right'>
                <label>{l s='Select import' mod='mpcarrierimport'}</label>
            </div>
            <div class='col-md-4'>
                <select class="input select chosen-single" id="select-import" data-placeholder='{l s='Select an option' mod='mpcarrierimport'}'>
                    <option/>
                    {foreach $options as $option}
                        <option value="{$option.id}">{$option.value}</option>
                    {/foreach}
                </select>
            </div>
        </div>
        <div class="row">
            <div class="col-md-3 text-right">
                <label>{l s='Select file' mod='mpcarrierimport'}</label>
            </div>
            <div class="col-md-4">
                <div class="form-group">
                    <input id="document_filename" type="file" name="document_filename" class="hide">
                    <div class="dummyfile input-group">
                        <span class="input-group-addon"><i class="icon-file"></i></span>
                        <input id="document_filename-name" type="text" name="filename" readonly="">
                        <span class="input-group-btn">
                            <button id="document_filename-selectbutton" type="button" name="submitAddAttachments" class="btn btn-default">
                                <i class="icon-folder-open"></i>
                                {l s='Add files' mod='mpcarrierimport'}
                            </button>
                        </span>
                    </div>
                    <div id="progress-wrp">
                        <div class="progress-bar"></div>
                        <div class="badge-white status">0%</div>
                    </div>
                </div>
                    
            </div>
        </div>
        <hr>
        <div class="container" id="content-table">

        </div>
    </div>
    <div class="panel-footer">
        <button type="button" class="btn btn-default pull-left" id="button-config">
            <i class="process-icon-cogs"></i>
            {l s='Config' mod='mpcarrierimport'}
        </button>
        <button type="button" class="btn btn-default pull-right" id="button-load">
            <i class="process-icon-download"></i>
            {l s='Load' mod='mpcarrierimport'}
        </button>
    </div>
</div>
                    
<script type="text/javascript">
    var Upload = function (file) {
        this.file = file;
    };

    Upload.prototype.getType = function() {
        return this.file.type;
    };
    Upload.prototype.getSize = function() {
        return this.file.size;
    };
    Upload.prototype.getName = function() {
        return this.file.name;
    };
    Upload.prototype.doUpload = function () {
        var that = this;
        var formData = new FormData();
        $('#content-table').html('');

        // add assoc key values, this will be posts values
        formData.append("file", this.file, this.getName());
        formData.append("upload_file", true);
        formData.append("import", $('#select-import').chosen().val());
        formData.append("ajax", true);
        formData.append("action", "loadFile");

        $.ajax({
            type: "POST",
            dataType: "json",
            xhr: function () {
                var myXhr = $.ajaxSettings.xhr();
                if (myXhr.upload) {
                    myXhr.upload.addEventListener('progress', that.progressHandling, false);
                }
                return myXhr;
            },
            success: function (data) {
                if (data.result) {
                    console.log(data.rows);
                    $('#content-table').html(data.tableHTML);
                    popSuccess('{l s='Table loaded' mod='mpcarrierimport'}');
                    bind();
                } else {
                    resetFile();
                    resetPB();
                    popError(data.error);
                }
                $('#button-load i').attr('class', '');
                $('#button-load i')
                    .attr('class', 'process-icon-download')
                    .css('color', '#555555');
            },
            error: function (error) {
                popError('{l s='Error parsing CSV file.' mod='mpcarrierimport'}');
                console.log(error)
            },
            async: true,
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            timeout: 60000
        });
    };

    Upload.prototype.progressHandling = function (event) {
        var percent = 0;
        var position = event.loaded || event.position;
        var total = event.total;
        var progress_bar_id = "#progress-wrp";
        if (event.lengthComputable) {
            percent = Math.ceil(position / total * 100);
        }
        // update progressbars classes so it fits your code
        $(progress_bar_id + " .progress-bar").css("width", +percent + "%");
        $(progress_bar_id + " .status").text(percent + "%");
    };

    $(document).ready(function(){
        $('.chosen-single').chosen();
        $('.chosen-single').on('change', function(){
            resetFile();
        });
        $('#document_filename-selectbutton').on('click', function(){
            $('#document_filename').click();
        });
        $('#document_filename').on('change', function(){
            $('#document_filename-name').val($('#document_filename').val().replace(/C:\\fakepath\\/i, ''));
            var file = $(this)[0].files[0];
            var upload = new Upload(file);
            // check size or type here with upload.getSize() and upload.getType()
            // execute upload
            upload.doUpload();
        });
        $('#button-config').on('click', function(){
            location.href='{$config_url}';
        });
        $('#button-load').on('click', function(){
            if (confirm('{l s='Import selected tracking?' mod='mpcarrierimport'}')) {
                var rows = [];
                var table = $('#content-table table');
                var chk = $(table).find('tbody input[type="checkbox"]:checked');
                $(chk).each(function(){
                    var tr = $(this).closest('tr');
                    var reference = String($(tr).find('td:nth-child(2)').text()).trim();
                    var tracking = String($(tr).find('td:nth-child(5)').text()).trim();
                    var delivered_date = String($(tr).find('td:nth-child(4)').text()).trim();

                    var row = {
                        'reference': reference,
                        'tracking_id': tracking,
                        'delivered_date': delivered_date 
                    };
                    rows.push(row);
                });
                $(this).find('i').removeClass('process-icon-download').addClass('process-icon-loading');
                $.ajax({
                    type: 'post',
                    dataType: 'json',
                    data:
                    {
                        rows: rows,
                        id_order_state: $('#change-status').val(),
                        ajax: true,
                        action: 'updateTracking'
                    },
                    success: function(response)
                    {
                        if(response.result) {
                            $(response.rows).each(function(){
                                updateRow(this.reference, this.result);
                            });
                        }
                        popSuccess('{l s='Tracking updated' mod='mpcarrierimport'}');
                        $('#button-load').find('i')
                            .addClass('process-icon-ok')
                            .addClass('color-green')
                            .removeClass('process-icon-loading');
                    },
                    error: function(response)
                    {
                        console.log(error);
                    }
                });
            }
        });
        activatePane();
    });
    
    function updateRow(reference, result)
    {
        var table = $('#content-table table');
        var tr = $(table).find('tbody tr');
        
        $(tr).each(function(){
            var col = $(this).find('td:nth-child(2)');
            var text = String($(col).text());
            if (text == reference) {
                if (result) {
                    $(col).css('background-color', '#4eb357')
                        .css('color', '#fcfcff')
                        .css('font-weight', 'bold');

                } else {
                    $(col).css('background-color', '#BB7979')
                        .css('color', '#fcfcff')
                        .css('font-weight', 'bold');
                }
                return true;
            }
        });
        return false;
    }

    function bind()
    {
        $('#check_all').off('change');
        $('#check-all').on('change', function(){
            var table = $('#content-table table');
            var chk = $(table).find('tbody input[type="checkbox"]').attr('checked', $(this).is(':checked'));
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

    function popError(message, title="{l s='Error' mod='mpcarrierimport'}")
    {
        $.growl.error({
            'title': title,
            'message': message
        });
    }

    function popSuccess(message, title="{l s='Operation Done' mod='mpcarrierimport'}")
    {
        $.growl.notice({
            'title': title,
            'message': message
        });
    }

    function popWarning(message, title="{l s='Warning' mod='mpcarrierimport'}")
    {
        $.growl.notice({
            'title': title,
            'message': message
        });
    }

    function resetPB()
    {
        $('#progress-wrp .progress-bar').css('width', 0);
        $('#progress-wrp .status').text('0 %');
    }

    function resetFile()
    {
        $('#document_filename').val('');
        $('#document_filename-name').val('');
    }
</script>   
