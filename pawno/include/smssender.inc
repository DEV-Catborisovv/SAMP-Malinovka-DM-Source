/**
--------------------------------------------------------------------------
|			|=== Romanius's ================================|			 |
|			| 			    SMS Sender Plugin   			|			 |
|			|======================== v0.1.2 ===============|			 |
|																		 |
|			|=== Authors: ==================================|			 |
|			|=> Romanius			(romanius@namba.kg)		|			 |
|			|===============================================|			 |
|																		 |
|  This script is free software: you can redistribute it and/or modify	 |
|  it under the terms of the GNU General Public License as published by	 |
|  the Free Software Foundation, either version 3 of the License, or	 |
|  (at your option) any later version.									 |
|																		 |
|  This script is distributed in the hope that it will be useful,		 |
|  but WITHOUT ANY WARRANTY; without even the implied warranty of		 |
|  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the		 |
|  GNU General Public License for more details.							 |
|																		 |
|  You should have received a copy of the GNU General Public License	 |
|  along with this script.  If not, see <http://www.gnu.org/licenses/>.	 |
|																		 |
--------------------------------------------------------------------------
**/

native SMSConnect(login[], password[]);		// Присоединение к серверу mail.ru
native SMSSend(phone[], message[]);			// Отправка СМС на указанный номер
native SMSDisconnect();						// Отсоединение от сервера

forward OnSMSError(phone[], error[]);
forward OnSMSAnswer(phone[], message[]);