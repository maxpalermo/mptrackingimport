<?php
/**
 * 2018 Digital Solutions®
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
 *  @author    Massimiliano Palermo <info@mpsoft.it>
 *  @copyright 2018 Digital Solutions®
 *  @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 *  International Registered Trademark & Property of Digital Solutions®
 */

require_once _PS_MODULE_DIR_.'mptrackingimport/classes/OrderTracking.php';

class AdminMpTrackingImportController extends ModuleAdminController {
    
    private $trackings;

    public function __construct()
    {
        $this->id_lang = (int)ContextCore::getContext()->language->id;
        $this->id_shop = (int)ContextCore::getContext()->shop->id;
        $this->link = new LinkCore();
        
        $this->bootstrap = true;
        $this->context = Context::getContext();
        $this->className = 'MpTrackingImport';
        $this->adminClassName = 'AdminMpTrackingImport';
        $this->token = Tools::getAdminTokenLite($this->adminClassName);
        $this->table = "orders";
        $this->identifier = "id_order";
        
        $this->bulk_actions = array(
            'import' => array(
                'text' => $this->l('Import selected'),
                'confirm' => $this->l('import selected tracking?'),
                'icon' => 'icon-download'
            ),
        );
        
        parent::__construct();
    }

    public function initToolbar()
    {
        /*
        [new] => Array
        (
            [href] => index.php?controller=AdminMpOutOfStock&addproduct&token=abe225d70a7555cfd65f980ceeddc561
            [desc] => Aggiungi nuovo
        )
        */
        parent::initToolbar();
        unset($this->toolbar_btn['new']);
        $this->toolbar_btn = array(
            'new' => array(
                'href' => '#',
                'desc' => $this->l('')
            )
        );
    }

    public function initContent()
    {
        $id_lang = Context::getContext()->language->id;

        if (Tools::isSubmit("submitBulkimportorders")) {
            $id_order_state = (int)Configuration::get("MP_CARRIER_IMPORT_ID_ORDER_STATE");
            $boxes = Tools::getValue('ordersBox', array());
            foreach ($boxes as $box) {
                $orderTracking = new OrderTracking($box);
                $db = Db::getInstance();
                $res = $db->update(
                    'order_carrier',
                    array(
                        'tracking_number' => $orderTracking->tracking,
                    ),
                    'id_order='.(int)$orderTracking->id
                );
                if ($res) {
                    if ($id_order_state) {
                        $order = new Order($orderTracking->id);
                        if ($order->current_state != $id_order_state) {
                            $order->setCurrentState($id_order_state);
                        }
                    }
                    $orderTracking->delete();
                } else {
                    $this->errors[] = sprintf($this->l('Unable to update order %s'), $orderTracking->reference);
                }
            }
            if ($this->errors) {
                $this->warnings = $this->l('Tracking imported with errors.');
            } else {
                $this->confirmations = $this->l('Tracking imported.');
            }
        }

        $this->fields_list = array(
            'id_order' => array(
                'title' => $this->l('Id Order'),
                'align' => 'right',
                'width' => 25,
            ),
            'reference' => array(
                'title' => $this->l('Reference'),
                'align' => 'left',
                'width' => 'auto',
                'filter_key' => 'a!reference'
            ),
            'date_add' => array(
                'title' => $this->l('Date order'),
                'type' => 'date',
                'align' => 'center',
                'width' => 'auto',
                'filter_key' => 'a!date_add',
            ),
            'customer' => array(
                'title' => $this->l('Customer'),
                'align' => 'left',
                'width' => 'auto',
                'filter_key' => 'c!customer',
            ),
            'tracking' =>array(
                'title' => $this->l('Tracking'),
                'align' => 'center',
                'width' => 'auto',
                'filter_key' => 'ot!tracking',
            ),
            'order_state' => array(
                'title' => $this->l('Current state'),
                'align' => 'left',
                'width' => 'auto',
                'type' => 'select',
                'list' => $this->getOrderStates(),
                'filter_key' => 'os!order_state',
            ),
        );
        if (Tools::isSubmit('submitImport')) {
            Configuration::updateValue("MP_CARRIER_IMPORT_ID_ORDER_STATE", Tools::getValue("id_order_state", 0));
            $id_orders = $this->getIdOrders();
        }
        
        $this->_select = 
            "CONCAT(c.firstname, ' ', c.lastname) as customer, os.name as order_state, ot.tracking as tracking";
        $this->_join =
            "LEFT JOIN "._DB_PREFIX_."customer `c` ON (a.id_customer=c.id_customer) ".
            "LEFT JOIN "._DB_PREFIX_."order_state_lang `os` ON (a.current_state=os.id_order_state and os.id_lang=".(int)$id_lang.")".
            "INNER JOIN "._DB_PREFIX_."order_tracking `ot` ON (a.id_order=ot.id_order)";

        $this->content = $this->renderForm();
        parent::initContent();
    }

    public function getIdOrders()
    {
        $file = Tools::fileAttachment("file_tracking");
        if (!$file) {
            return false;
        }
        $file_nl = explode("\n", $file['content']);
        $csv = array();
        foreach($file_nl as $row) {
            if ($row) {
                $csv[] = str_getcsv($row, ",");
            }
        }

        $id_orders = array();
        OrderTracking::truncate();

        if (Tools::getValue('type_tracking', 0) == 1) {
            $header = array_shift($csv);
            $this->tracking = array();
            foreach($csv as &$row) {
                if (count($row) == count($header)) {
                    $row = array_combine($header, $row);
                    $id_order = $this->getIdorderByReference($row['VABRMN']);
                    if ($id_order) {
                        $id_orders[] = $id_order;
                        $tracking_row = array(
                            'id_order' => $id_order,
                            'reference' => $row['VABRMN'],
                            'tracking' => $row['VABSPED'],
                        );
                        $orderTracking = new OrderTracking();
                        $orderTracking->force_id = true;
                        $orderTracking->id = $id_order;
                        $orderTracking->reference = $row['VABRMN'];
                        $orderTracking->tracking = $row['VABSPED'];
                        $orderTracking->add();
                        $this->tracking[] = $tracking_row;
                    }
                }
            }
        }

        return implode(",", $id_orders);
    }

    public function getIdOrderByReference($reference)
    {
        $db = Db::getInstance();
        $sql = "select id_order from "._DB_PREFIX_."orders where reference = '".pSQL($reference)."'";
        return (int)$db->getValue($sql);
    }

    public function getCmbOrderStates()
    {
        $id_lang = Context::getContext()->language->id;
        $db = Db::getInstance();
        $sql = "select id_order_state, name from "._DB_PREFIX_."order_state_lang where id_lang=".(int)$id_lang." order by name";
        $rows = $db->executeS($sql);
        if ($rows) {
            return $rows;
        }
        return array();
    }

    public function getOrderStates()
    {
        $id_lang = Context::getContext()->language->id;
        $db = Db::getInstance();
        $sql = "select id_order_state, name from "._DB_PREFIX_."order_state_lang where id_lang=".(int)$id_lang." order by name";
        $rows = $db->executeS($sql);
        $output = array();

        if ($rows) {
            foreach($rows as $row) {
                $output[$row['name']] = $row['name'];
            }
        }
        
        return $output;
    }

    public function renderForm()
    {
        $this->fields_form = array( 
            'form' => array(
                //'tinymce' => true,
                'legend' => array(
                    'title' => $this->module->l('Import Tracking'),
                    'icon' => 'icon-truck',
                ),
                'input' => array(
                    array(
                        'type' => 'file',
                        'label' => $this->module->l('Tracking CSV'),
                        'name' => 'file_tracking',
                        'class' => 'fixed-width-xl',
                        'lang' => false,
                        'hint' => $this->module->l('File CSV with tracking'),
                    ),
                    array(
                        'type' => 'select',
                        'label' => $this->module->l('Import Type'),
                        'name' => 'type_tracking',
                        'class' => 'fixed-width-xl',
                        'lang' => false,
                        'hint' => $this->module->l('Choose Import type'),
                        'options' => array(
                            'query' => array(
                                array(
                                    'id_carrier' => 1,
                                    'label' => $this->l('Import Brt VAB'),
                                ),
                                array(
                                    'id_carrier' => 2,
                                    'label' => $this->l('Import Brt VAC'),
                                ),
                                array(
                                    'id_carrier' => 3,
                                    'label' => $this->l('Import Sogetras'),
                                ),
                            ),
                            'id' => 'id_carrier',
                            'name' => 'label',
                        ),
                    ),
                    array(
                        'type' => 'select',
                        'label' => $this->module->l('Change order state'),
                        'name' => 'id_order_state',
                        'class' => 'fixed-width-xl chosen',
                        'lang' => false,
                        'hint' => $this->module->l('Change order state after tracking'),
                        'options' => array(
                            'query' => $this->getCmbOrderStates(),
                            'id' => 'id_order_state',
                            'name' => 'name',
                        ),
                    ),
                ),
                'submit' => array(
                    'title' => $this->l('Import'),
                    'class' => 'btn btn-default pull-right',
                    'icon' => 'process-icon-cogs',
                ),
            )
        ); 
        
        $this->helper = new HelperForm();
        $this->helper->show_toolbar = true;
        $this->helper->table = "orders";
        $lang = new Language((int)Configuration::get('PS_LANG_DEFAULT'));
        $this->helper->default_form_language = $lang->id;
        $this->helper->allow_employee_form_lang =
            Configuration::get('PS_BO_ALLOW_EMPLOYEE_FORM_LANG') ? Configuration::get('PS_BO_ALLOW_EMPLOYEE_FORM_LANG') : 0;
        $this->helper->identifier = "id_order";
        $this->helper->submit_action = 'submitImport';
        $this->helper->currentIndex = $this->context->link->getAdminLink($this->adminClassName, false);
        $this->helper->token = Tools::getAdminTokenLite($this->adminClassName);
        $this->helper->tpl_vars = array(
            'fields_value' => array(
                'type_tracking' => Tools::getValue('type_tracking', 0),
                'id_order_state' => (int)Tools::getValue('id_order_state', (int)Configuration::get("MP_CARRIER_IMPORT_ID_ORDER_STATE"))
            ),
            'languages' => $this->context->controller->getLanguages(),
            'id_language' => $this->context->language->id
        );
    
        return $this->helper->generateForm(array($this->fields_form));
    }

    /**
     * Function used to render the list to display for this controller
     *
     * @return string|false
     * @throws PrestaShopException
     */
    public function renderList()
    {   
        if (!($this->fields_list && is_array($this->fields_list))) {
            return false;
        }
        $this->getList($this->context->language->id);
        
        // If list has 'active' field, we automatically create bulk action
        if (isset($this->fields_list) && is_array($this->fields_list) && array_key_exists('active', $this->fields_list)
            && !empty($this->fields_list['active'])) {
            if (!is_array($this->bulk_actions)) {
                $this->bulk_actions = array();
            }

            $this->bulk_actions = array_merge(array(
                'enableSelection' => array(
                    'text' => $this->l('Enable selection'),
                    'icon' => 'icon-power-off text-success'
                ),
                'disableSelection' => array(
                    'text' => $this->l('Disable selection'),
                    'icon' => 'icon-power-off text-danger'
                ),
                'divider' => array(
                    'text' => 'divider'
                )
            ), $this->bulk_actions);
        }

        $helper = new HelperList();

        // Empty list is ok
        if (!is_array($this->_list)) {
            $this->displayWarning($this->l('Bad SQL query', 'Helper').'<br />'.htmlspecialchars($this->_list_error));
            $this->displayWarning($this->_listsql);
            return false;
        }

        $this->setHelperDisplay($helper);
        $helper->_default_pagination = $this->_default_pagination;
        $helper->_pagination = $this->_pagination;
        $helper->tpl_vars = $this->getTemplateListVars();
        $helper->tpl_delete_link_vars = $this->tpl_delete_link_vars;

        // For compatibility reasons, we have to check standard actions in class attributes
        foreach ($this->actions_available as $action) {
            if (!in_array($action, $this->actions) && isset($this->$action) && $this->$action) {
                $this->actions[] = $action;
            }
        }

        $helper->is_cms = $this->is_cms;
        $helper->sql = $this->_listsql;

        $list = $helper->generateList($this->_list, $this->fields_list);
        
        return $list;
    }

    public function processToggleStatus()
    {
        $boxes = Tools::getValue('productBox');
        if ($boxes) {
            foreach ($boxes as $box) {
                $product = new Product($box);
                $product->toggleStatus();
            }
        }
        return true;
    }

    public function processDoChanges()
    {
        $boxes = Tools::getValue('productBox');
        if ($boxes) {
            $listBoxes = implode(",", $boxes);
            $db = Db::getInstance();
            $res = $db->update(
                'product',
                array(
                    'out_of_stock' => $this->out_of_stock
                ),
                'id_product in ('.$listBoxes.')'
            );

            if ($res) {
                $this->confirmations[] = $this->module->displayConfirmation(
                    $this->l('Selected products has been updated.')
                );
            } else {
                $this->errors[] = $this->displayError(
                    $this->l('Error updating selected products.')
                );
            }

            $res = $db->update(
                'stock_available',
                array(
                    'out_of_stock' => $this->out_of_stock
                ),
                'id_product in ('.$listBoxes.')'
            );

            if ($res) {
                $this->confirmations[] = $this->module->displayConfirmation(
                    $this->l('Selected stock products has been updated.')
                );
            } else {
                $this->errors[] = $this->displayError(
                    $this->l('Error updating selected stock products.')
                );
            }
        }
    }

    public function displayAcceptLink($token = null, $id = 0, $name = null)
    {
        /*
        $token will contain token variable
        $id will hold id_identifier value
        $name will hold display name
        */
        $smarty = $this->context->smarty;
        $path = _PS_MODULE_DIR_.$this->module->name.'/views/templates/hook/rowaction.tpl';
        $smarty->assign(
            array(
                'id' => $id,
                'href' => 'javascript:doChange("accept", "'.$id.'");',
                'title' => $this->l('Accept'),
                'icon' => 'icon-thumbs-up',
                'name' => $name,
                'token' => $token,
            )
        );
        return $smarty->fetch($path);
    }

    public function displayRefuseLink($token = null, $id = 0, $name = null)
    {
        /*
        $token will contain token variable
        $id will hold id_identifier value
        $name will hold display name
        */
        $smarty = $this->context->smarty;
        $path = _PS_MODULE_DIR_.$this->module->name.'/views/templates/hook/rowaction.tpl';
        $smarty->assign(
            array(
                'id' => $id,
                'href' => 'javascript:doChange("refuse", "'.$id.'");',
                'title' => $this->l('Refuse'),
                'icon' => 'icon-thumbs-down',
                'name' => $name,
                'token' => $token,
            )
        );
        return $smarty->fetch($path);
    }

    public function displayDefLink($token = null, $id = 0, $name = null)
    {
        /*
        $token will contain token variable
        $id will hold id_identifier value
        $name will hold display name
        */
        $smarty = $this->context->smarty;
        $path = _PS_MODULE_DIR_.$this->module->name.'/views/templates/hook/rowaction.tpl';
        $smarty->assign(
            array(
                'id' => $id,
                'href' => 'javascript:doChange("default", "'.$id.'");',
                'title' => $this->l('Default'),
                'icon' => 'icon-asterisk',
                'name' => $name,
                'token' => $token,
            )
        );
        return $smarty->fetch($path);
    }

    public function ajaxProcessDoChangeRow()
    {
        $id = (int)Tools::getValue('id', 0);
        $type = Tools::getValue('type', 'default');
        $array = array(
            'refuse' => 0,
            'accept' => 1,
            'default' => 2,
        );
        $value = (int)$array[$type];
        $db = Db::getInstance();
        $res = $db->update(
            'product',
            array(
                'out_of_stock' => $value
            ),
            'id_product = '.$id
        );
        if (!$res) {
            print Tools::jsonEncode(
                array(
                    'result' => false,
                )
            );
            exit();
        }
        $res = $db->update(
            'stock_available',
            array(
                'out_of_stock' => $value
            ),
            'id_product = '.$id
        );
        if (!$res) {
            print Tools::jsonEncode(
                array(
                    'result' => false,
                )
            );
            exit();
        }
        print Tools::jsonEncode(
            array(
                'result' => true,
            )
        );
        exit();
    }

}
