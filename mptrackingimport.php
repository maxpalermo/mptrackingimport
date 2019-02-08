<?php
/**
* 2007-2018 PrestaShop
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
*  @author    Massimiliano Palermo <mpsoft.it>
*  @copyright 2019 Digital Solution®
*  @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*/

if (!defined('_PS_VERSION_')) {
    exit;
}

class MpTrackingImport extends Module
{
    public function __construct()
    {
        $this->name = 'mptrackingimport';
        $this->tab = 'administration';
        $this->version = '1.5.0';
        $this->author = 'Digital Solutions®';
        $this->need_instance = 0;
        $this->ps_versions_compliancy = array('min' => '1.6', 'max' => _PS_VERSION_); 
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->l('MP Tracking Import');
        $this->description = $this->l('Update track order status via CSV');
        $this->confirmUninstall = $this->l('Are you sure you want to uninstall?');
        $this->context = Context::getContext();
        $this->smarty = $this->context->smarty;
        $this->id_lang = (int)$this->context->language->id;
        $this->id_employee = (int)$this->context->employee->id;
        $this->adminClassName = 'AdminMpTrackingImport';
        $this->carriers = Carrier::getCarriers($this->id_lang);
    }
  
    
    /**
     * Get The URL path of this module
     * @return string The URL of this module
     */
    public function getUrl()
    {
        return $this->_path;
    }
    
    /**
     * Return the physical path of this module
     * @return string The path of this module
     */
    public function getPath()
    {
        return $this->local_path;
    }

    public function install()
    {
      if (Shop::isFeatureActive()) {
        Shop::setContext(Shop::CONTEXT_ALL);
      }

      $menu = $this->installTab($this->name, 'AdminParentShipping', $this->adminClassName, $this->l('MP Tracking Import'));
      if (!$menu) {
        $this->_error[] = $this->l('Unable to install menu');
        return false;
      }

      if (!parent::install()) {
        $this->_error[] = $this->l('Unable to install module.');
        return false;
      }

      if (!$this->installSQL()) {
        $this->_error[] = $this->l('Unable to install database table.');
        return false;
      }

      return true;
    }
    
    public function uninstall()
    {
        $tab = new InstallTab($this);

        if(!$tab->uninstallTab($this->adminClassName)) {
            $this->_error[] = $this->l('Unable to remove menu.');
            return false;
        }

        /*
        if(!$this->uninstallSQL()) {
            $this->addError($this->l('Unable to remove database table.'));
            return false;
        }
        */

        if(!parent::uninstall()) {
            $this->_error[] = $this->l('Unable to remove this module');
            return false;
        }

        return true;
    }

    /**
     *
     * @param string $parent Parent tab name
     * @param type $class_name Class name of the module
     * @param type $name Display name of the module
     * @param type $active If true, Tab menu will be shown
     * @return boolean True if successfull, False otherwise
     */
    public function installTab($module_name, $parent, $class_name, $name, $active = 1)
    {
        // Create new admin tab
        $tab = new Tab();
        $id_parent = (int)Tab::getIdFromClassName($parent);
        PrestaShopLoggerCore::addLog('Install main menu: id=' . (int)$id_parent);
        if (!$id_parent) {
            if (!$this->installMainMenu()) {
                return false;
            }
        }
        $tab->id_parent = (int)$id_parent;
        $tab->name      = array();
        
        foreach (Language::getLanguages(true) as $lang) {
            $tab->name[$lang['id_lang']] = $name;
        }
        
        $tab->class_name = $class_name;
        $tab->module     = $module_name;
        $tab->active     = $active;
        
        if (!$tab->add()) {
            return false;
        }
        return true;
    }

    public function installMainMenu($main_menu = null, $main_menu_name = null)
    {
        if (!$main_menu) {
            $main_menu = 'MpModules';
            $main_menu_name = $this->module->l('MP Modules');
        }
        $id_mp_menu = (int) TabCore::getIdFromClassName($main_menu);
        if ($id_mp_menu == 0) {
            $tab = new TabCore();
            $tab->active = 1;
            $tab->class_name = $main_menu;
            $tab->id_parent = 0;
            $tab->module = null;
            $tab->name = array();
            foreach (Language::getLanguages(true) as $lang) {
                $tab->name[$lang['id_lang']] = $main_menu_name;
            }
            $id_mp_menu = $tab->add();
            if ($id_mp_menu) {
                PrestaShopLoggerCore::addLog('id main menu: '.(int)$id_mp_menu);
                return (int)$tab->id;
            } else {
                PrestaShopLoggerCore::addLog('id main menu error');
                return false;
            }
        }
    }

    /**
     * Uninstall a menu
     * @param string pe $class_name Class name of the module
     * @return boolean True if successfull, False otherwise
     */
    public function uninstallTab($class_name)
    {
        $id_tab = (int)Tab::getIdFromClassName($class_name);
        if ($id_tab) {
            $tab = new Tab((int)$id_tab);
            return $tab->delete();
        } else {
            return true;
        }
    }

    private function installSQL()
    {
        $sql = array(
            "CREATE TABLE IF NOT EXISTS "._DB_PREFIX_."order_tracking (",
            "id_order INT NOT NULL AUTO_INCREMENT PRIMARY KEY,",
            "reference VARCHAR(255) NOT NULL,",
            "tracking VARCHAR(255) NOT NULL)",
            "ENGINE=INNODB;"
        );
        return Db::getInstance()->execute(implode(" ", $sql));
    }
}